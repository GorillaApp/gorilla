desc "Run all unit tests"
task :test => [ "coffeelint", "spec", "konacha:run" ]
