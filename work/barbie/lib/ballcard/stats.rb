require 'erb'

module Ballcard

  # = Simple Code Statistics Plugin
  #
  # The Stats plugin is a simple code statistics analyizer,
  # producing a basic LOC analysis.
  #
  # TODO: Add support for qed? (how?).
  #
  # TODO: Add support for POM?
  #
  class Stats #< Service

    # Default folder to store generated files.
    DEFAULT_OUTPUT = 'log/stats'

    # Default folder(s) to find test scripts.
    DEFAULT_TESTPATH = ['test']

    # Default folders and/or file patterns to exclude from analysis.
    DEFAULT_EXCLUDE = ['ext']

    # Directories to scan for scripts. The default is the project's loadpath.
    attr_accessor :loadpath

    # Files patterns to specially exclude from loadpath.
    # Default is ['ext'] b/c this does not yet support C analysis.
    attr_accessor :exclude

    # Directories to scan for tests. The default is test/.
    attr_accessor :testpath

    # Output directory. Default is log/stats/. This should alway be
    # a dedicated directory because mutiple files are generated
    # with generic names, eg. +index.html+.
    attr_accessor :output

    # Title of pacakge. Thisis used to put a header in the output.
    attr_accessor :title

    # Setup default attribute values.
    def initialize_defaults
      #@title    = metadata.title #|| metadata.package
      #@loadpath = metadata.loadpath #|| ['lib']
      @testpath = DEFAULT_TESTPATH
      @exclude  = DEFAULT_EXCLUDE
      #@output   = project.log + DEFAULT_FOLDER
      @output   = DEFAULT_OUTPUT
    end

    # Scan source code counting files, lines of code and
    # comments and presents a report of it's findings.
    #
    # TODO: Add C support for ext/.
    #
    def analyize
      loadpath = self.loadpath.to_list
      exclude  = self.exclude.to_list

      files = multiglob_r(*loadpath) - multiglob_r(*exclude)

      #() #.inject([]){ |memo, find| memo.concat(glob(find)); memo }
      #Dir.multiglob_with_default(DEFAULT_STATS_FILES)

      if output.outofdate?(*files) or force?
        generate_stats(files)
      else
        out = output.relative_path_from(project.root)
        report "Stats are current (#{out})."
      end
    end

  private

    # Save stats to output.
    #
    def save_stats(file, text)
      log_file = output + file
      if dryrun?
        report "write #{log_file}"
      else
        mkdir_p(log_file.parent)
        write(log_file, text)
        rfile = log_file.relative_path_from(project.root)
        status "Updated #{rfile}"
      end
    end

    #
    def testfiles
      @testfiles ||= multiglob_r(*testpath)
    end

    # Figure out the statistics.
    #
    def generate_stats(files)
      fc, l, c, r, t, s = *line_count(*files)

      fct, lt, ct, rt, tt, st = *([0]*6)
      if File.directory?('test')
        fct, lt, ct, rt, tt, st = *line_count(*testfiles)
        t = lt if lt > 0
      end

      rat = lambda do |d,n|
        if d == 0 or n == 0
          "-"
        elsif d > n and n != 0
          "%.1f" % [ d.to_f / n ]
        elsif n > d and n != 0
          "%.1f" % [ d.to_f / n ]
          #'-' #"%.1f:1" % [ n.to_f / d ]
        else
          "1.0"
        end
      end

      per = lambda do |n,d|
        if d != 0
          (((n.to_f / d)*100).to_i).to_s + "%"
        else
          "-"
        end
      end

      max = l.to_s.size + 4

      head = ["Total", "Code", "-%-", "Docs", "-%-", "Blank", "-%-", "Files"]
      prod = [l.to_s, c.to_s, per[c,l], r.to_s, per[r,l], s.to_s, per[s,l], fc]
      test = [lt.to_s, ct.to_s, per[ct,l], rt.to_s, per[rt,l], st.to_s, per[st,l], fct]
      totl = [(l+lt), (c+ct), per[c+ct,l+lt], (r+rt), per[r+rt,l+lt], (s+st), per[s+st,l+lt], (fc+fct)]

      # produce .txt file
      text = gen_text(head, prod, test, totl, rat, c, r, s, t, l)
      save_stats('stats.txt', text)

      # produce .html file
      text = gen_html(head, prod, test, totl, rat, c, r, s, t, l)
      save_stats('index.html', text)
    end

    # Return line counts for files.
    #
    def line_count(*files)
      files = files.select{ |f| /\.rb/ =~ f && File.file?(f) }

      #files = files.inject([]) do |memo, find|
      #  glob = Dir.glob(find).map{ |f| File.file?(f) }
      #  memo.concat(glob)
      #  memo
      #end

      fc, l, c, t, r = 0, 0, 0, 0, 0
      bt, rb = false, false

      files.each do |fname|
        next unless fname =~ /\.rb$/      # TODO should this be done?
        fc += 1
        File.open( fname ) do |f|
          while line = f.gets
            l += 1
            next if line =~ /^\s*$/
            case line
            when /^=begin\s+test/
              tb = true; t+=1
            when /^=begin/
              rb = true; r+=1
            when /^=end/
              t+=1 if tb
              r+=1 if rb
              rb, tb = false, false
            when /^\s*#/
              r += 1
            else
              c+=1 if !(rb or tb)
              r+=1 if rb
              t+=1 if tb
            end
          end
        end
      end
      s = l - c - r - t

      return fc, l, c, r, t, s
    end

      #puts "FILES:"
      #puts "  source: #{fc}"
      #puts "  test  : #{fct}"
      #puts "  total : #{fc+fct}"
      #puts
      #puts "LINES:"
      #puts "  code  : %#{max}s   %4s" % [ c.to_s, per[c,l] ]
      #puts "  docs  : %#{max}s   %4s" % [ r.to_s, per[r,l] ]
      #puts "  space : %#{max}s   %4s" % [ s.to_s, per[s,l] ]
      #puts "  test  : %#{max}s   %4s" % [ t.to_s, per[t,l] ]
      #puts "  total : %#{max}s   %4s" % [ l.to_s, per[l,l] ]
      #puts
      #puts "Ratio to 1 :"
      #puts "  code to test : #{rat[c,t]} #{per[c,t]}"

    # Builds the text-based layout.
    #
    def gen_text(head, prod, test, totl, rat, c, r, s, t, l)
      max  = 8
      text = []
      text << "#{title} Statistics"
      text << Time.now.to_s
      text << ""
      text << "TYPE    %#{max}s %#{max}s %4s %#{max}s %4s %#{max}s %4s %#{max}s" % head
      text << "Source  %#{max}s %#{max}s %4s %#{max}s %4s %#{max}s %4s %#{max}s" % prod
      text << "Test    %#{max}s %#{max}s %4s %#{max}s %4s %#{max}s %4s %#{max}s" % test
      text << "Total   %#{max}s %#{max}s %4s %#{max}s %4s %#{max}s %4s %#{max}s" % totl
      text << ""
      text << "RATIO     Code    Docs    Blank   Test   Total"
      text << "Code   %7s %7s %7s %7s %7s" % [ rat[c,c], rat[c,r], rat[c,s], rat[c,t], rat[c,l] ]
      text << "Docs   %7s %7s %7s %7s %7s" % [ rat[r,c], rat[r,r], rat[r,s], rat[r,t], rat[r,l] ]
      text << "Blank  %7s %7s %7s %7s %7s" % [ rat[s,c], rat[s,r], rat[s,s], rat[s,t], rat[s,l] ]
      text << "Test   %7s %7s %7s %7s %7s" % [ rat[t,c], rat[t,r], rat[t,s], rat[t,t], rat[t,l] ]
      text << "Total  %7s %7s %7s %7s %7s" % [ rat[l,c], rat[l,r], rat[l,s], rat[l,t], rat[l,l] ]
      text << ""
      text = text.join("\n")
      text
    end

    # Read template by name.
    def template(name)
      file = File.join(File.dirname(__FILE__), 'template', name)
      File.read(file)
    end

    # Builds the HTML-based layout.
    #
    # TODO: Need to improve the microformat-ness of stats output.
    def gen_html(head, prod, test, totl, rat, c, r, s, t, l)
      ERB.new(template('index.html'))
      template.result(binding)
    end

=begin
    def gen_html(head, prod, test, totl, rat, c, r, s, t, l)
      %{
        <html>
        <head>
          <title>#{title} Code Statistics</title>
          <style>
            h2{margin: 5px 0;}
            table{width: 95%;}
            th{background: #dcc;}
            td{padding: 5px;}
            .basic_stats{margin: 0 auto; width: 800px;}
          </style>
          <link rel="stylesheet" type="text/css" href="stats.css"/>
        </head>
        <body>
        <div class="basic_stats">
          <h1>#{title} -- Basic Code Statistics</h1>
          <table class="counts" border="1">
            <tr><th colspan="9"><h2>Counts</h2></th></tr>
            #{ html_rowh % [ "TYPE"  , *head ] }
            #{ html_rowd % [ "Source", *prod ] }
            #{ html_rowd % [ "Test"  , *test ] }
            #{ html_rowd % [ "Total" , *totl ] }
          </table>
          <br/>
          <table class="ratios" border="1">
            <tr><th colspan="6"><h2>Ratios</h2></th></tr>
            <tr><th>x:1</th><th>Code</th><th>Docs</th><th>Blank</th><th>Test</th><th>Total</th></tr>
            #{ html_row2 % [ "Code"  , rat[c,c], rat[c,r], rat[c,s], rat[c,t], rat[c,l] ] }
            #{ html_row2 % [ "Docs"  , rat[r,c], rat[r,r], rat[r,s], rat[r,t], rat[r,l] ] }
            #{ html_row2 % [ "Blank" , rat[s,c], rat[s,r], rat[s,s], rat[s,t], rat[s,l] ] }
            #{ html_row2 % [ "Test"  , rat[t,c], rat[t,r], rat[t,s], rat[t,t], rat[t,l] ] }
            #{ html_row2 % [ "Total" , rat[l,c], rat[l,r], rat[l,s], rat[l,t], rat[l,l] ] }
          </table>
          <br/>
          <div class="date">#{Time.now.to_s}</div>
        </div>
        </body>
        </html>
      }
    end
=end

    def html_rowh
      html_rowd.gsub('td', 'th')
    end

    def html_rowd
      "<tr><th>%s</th><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>"
    end

    def html_row2
      "<tr><th>%s</th><td>%7s</td><td>%7s</td><td>%7s</td><td>%7s</td><td>%7s</td></tr>"
    end

  end

end

