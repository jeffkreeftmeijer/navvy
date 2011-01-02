Gem::Specification.new do |gem|
  gem.name    = 'navvy'
  gem.version = '0.3.0'
  gem.date    = Date.today.to_s

  gem.summary = "Simple background job processor inspired by delayed_job, but aiming for database agnosticism."
  gem.description = "Simple background job processor inspired by delayed_job, but aiming for database agnosticism."

  gem.authors  = ['Jeff Kreeftmeijer']
  gem.email    = 'jeff@kreeftmeijer.nl'
  gem.homepage = 'http://github.com/jeffkreeftmeijer/navvy'

  gem.files = Dir['{generators,lib,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  gem.add_development_dependency('rake')
  gem.add_development_dependency('sqlite3-ruby')
  gem.add_development_dependency('bson_ext')
  gem.add_development_dependency('rspec', ["~> 2.0"])
  gem.add_development_dependency('yard', [">= 0.5.2"])
  gem.add_development_dependency('timecop', [">= 0.3.5"])
  gem.add_development_dependency('fuubar', ["~> 0.0"])
end
