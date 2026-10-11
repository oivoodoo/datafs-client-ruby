Gem::Specification.new do |spec|
  spec.name = "datafs-client"
  spec.version = "0.1.0"
  spec.summary = "Ruby client for a self-hosted DataFS install."
  spec.authors = ["DataFS contributors"]
  spec.license = "MIT"
  spec.files = Dir["lib/**/*.rb", "README.md", "API.md", "LICENSE"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.1"
end
