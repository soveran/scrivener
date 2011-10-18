require "./lib/scrivener"

Gem::Specification.new do |s|
  s.name              = "scrivener"
  s.version           = Scrivener::VERSION
  s.summary           = "Validation frontend for models."
  s.description       = "Scrivener removes the validation responsibility from models and acts as a filter for whitelisted attributes."
  s.authors           = ["Michel Martens"]
  s.email             = ["michel@soveran.com"]
  s.homepage          = "http://github.com/soveran/scrivener"
  s.files = Dir[
    "LICENSE",
    "AUTHORS",
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/**/*.rb"
  ]
  s.add_development_dependency "cutest"
end
