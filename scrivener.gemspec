require "./lib/scrivener"

Gem::Specification.new do |s|
  s.name         = "scrivener"
  s.version      = Scrivener::VERSION
  s.summary      = "Validation frontend for models."
  s.description  = "Scrivener removes the validation responsibility from models and acts as a filter for whitelisted attributes."
  s.authors      = ["Michel Martens"]
  s.email        = ["michel@soveran.com"]
  s.homepage     = "http://github.com/soveran/scrivener"
  s.license      = "MIT"

  s.files = `git ls-files`.split("\n")

  s.add_development_dependency "cutest"
end
