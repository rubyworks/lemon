# 2011-07-07 | Nailing Down the Nomenclature

I have finally settled on `test_class` and `test_module` as thew new toplevel method for defining Lemon test cases. I decided against reusing `test_case` from Citron b/c I determined it is best that these types of test cases not be mixed together, but rather stay cleanly separated.

I also decided against the original KO inspired nomenclature of `Test.case`. Though it looks very cool at first glance, in the end it goes against the grain. For instance, would one design an RSpec-stlye nomenclature as `Test.describe`, or a Cucumber-style nomenclature using `Test.feature`? While one could do so, it's completely uneccessry.

