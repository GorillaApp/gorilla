desc "Run all unit tests"
task :test => [ "test:spec", "test:konacha" ]

namespace :test do
  desc "Run RSpec Tests"
  task :spec => "spec"

  desc "Run Konacha Tests"
  task :konacha => "konacha:run"
end
