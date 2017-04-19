#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/awscli:1
  - class: EnvVarRequirement
    envDef:
      - envName: "AWS_CONFIG_FILE"
        envValue: $(inputs.aws_config.path)
      - envName: "AWS_SHARED_CREDENTIALS_FILE"
        envValue: $(inputs.aws_shared_credentials.path)
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  - id: aws_config
    type: File

  - id: aws_shared_credentials
    type: File

  - id: endpoint_json
    type: File
    inputBinding:
      loadContents: true
      valueFrom: null

  - id: signpost_json
    type: File
    inputBinding:
      loadContents: true
      valueFrom: null

outputs:
  - id: output
    type: File
    outputBinding:
      glob: |
        ${
        var signpost_json = JSON.parse(inputs.signpost_json.contents);
        var signpost_url = String(signpost_json.urls.slice(0));
        var file_name = signpost_url.split('/').slice(-1)[0];
        return file_name
        }

arguments:
  - valueFrom: "aws"
    position: 0
    shellQuote: true

  - valueFrom: "s3"
    position: 1
    shellQuote: true

  - valueFrom: "cp"
    position: 2
    shellQuote: true

  - valueFrom: |
      ${
      var signpost_json = JSON.parse(inputs.signpost_json.contents);
      var signpost_url = String(signpost_json.urls.slice(0));
      var signpost_path = signpost_url.slice(5);
      var signpost_array = signpost_path.split('/');
      var signpost_root = signpost_array[0];
      var profile = signpost_root;
      var endpoint_json = JSON.parse(inputs.endpoint_json.contents);
      var endpoint_url = String(endpoint_json[profile]);
      return endpoint_url
      }
    prefix: --endpoint-url
    position: 4
    shellQuote: true

  - valueFrom: |
      ${
      var signpost_json = JSON.parse(inputs.signpost_json.contents);
      var signpost_url = String(signpost_json.urls.slice(0));
      var signpost_path = signpost_url.slice(5);
      var signpost_array = signpost_path.split('/');
      var signpost_root = signpost_array[0];
      var profile = signpost_root;
      return profile
      }
    prefix: --profile
    position: 5
    shellQuote: true

  - valueFrom: |
      ${
      var signpost_json = JSON.parse(inputs.signpost_json.contents);
      var obj_path = [];
      obj_path.push(signpost_json.urls[0]);
      var signpost_path = obj_path[0].substring(5).split('/').slice(1).join('/');
      var s3_url = "s3://" + signpost_path;
      return s3_url
      }
    position: 98
    shellQuote: true

  - valueFrom: .
    position: 99
    shellQuote: true

baseCommand: []
