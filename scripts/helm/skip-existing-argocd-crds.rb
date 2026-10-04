#!/usr/bin/env ruby

require "yaml"

# Helm post-renderer for clusters that already provide Argo CD/Workflows CRDs.
# Keep the Devtron controllers and RBAC, but do not make this release own
# cluster-scoped CRDs used by another platform (for example OpenChoreo).

existing_crds = %w[
  applications.argoproj.io
  applicationsets.argoproj.io
  appprojects.argoproj.io
  clusterworkflowtemplates.argoproj.io
  cronworkflows.argoproj.io
  workflowartifactgctasks.argoproj.io
  workfloweventbindings.argoproj.io
  workflows.argoproj.io
  workflowtaskresults.argoproj.io
  workflowtasksets.argoproj.io
  workflowtemplates.argoproj.io
]

documents = YAML.load_stream(STDIN)
documents.reject! do |document|
  document.is_a?(Hash) &&
    document["kind"] == "CustomResourceDefinition" &&
    existing_crds.include?(document.dig("metadata", "name"))
end

documents.each do |document|
  puts "---"
  puts YAML.dump(document).sub(/^---\n/, "")
end
