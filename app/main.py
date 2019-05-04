#!/usr/bin/env python3

from flask import Flask
from flask_restplus import Resource, Api, fields
import json
import re
import logging
import sys
from werkzeug.middleware.proxy_fix import ProxyFix
from healthcheck import HealthCheck

# Init
app = Flask(__name__)
app.wsgi_app = ProxyFix(app.wsgi_app)
api = Api(app, version='1.0', title='GoodRx AMI Builds',
    description='Get AMI build information',
)

# Generic Class for AMI Build Info
class AMIBuildInfo():
    def __init__(self, json_input, is_file=False):
        if is_file:
            with open(json_input) as content:
                self.jobs = json.load(content)
        else:
            self.jobs = json_input

    def check_jobs(self, is_file=False):
        if "jobs" not in self.jobs:
            if is_file:
                logging.critical("Jobs key missing from JSON!")
                sys.exit(1)
            else:
                api.abort(404, "Jobs key missing from JSON!")
            
    def check_build_base_ami_section(self, is_file=False):
        self.check_jobs()
        for job in self.jobs['jobs']:
            if "Build base AMI" not in job:
                if is_file:
                    logging.critical("Build base AMI key missing from JSON!")
                    sys.exit(1)
                else:
                    api.abort(404, "Build base AMI key missing from JSON!")

    def check_builds_section(self, is_file=False):
        self.check_build_base_ami_section()
        if "Builds" not in self.jobs['jobs']['Build base AMI']:
            if is_file:
                logging.critical("Build base AMI key missing from JSON!")
                sys.exit(1)
            else:
                api.abort(404, "Builds key missing from JSON!")

    def latest_build(self):
        self.check_builds_section()
        build_statuses = self.jobs['jobs']['Build base AMI']['Builds']
        # Assume build dates are epoch timestamps
        latest_build_info = max(build_statuses, key=lambda x : x['build_date'])
        return dict((k, latest_build_info[k]) for k in ('build_date', 'output'))

    def latest_build_data(self):
        latest_build_info = self.latest_build()
        output_list = latest_build_info['output'].split()
        ami_id_regex = re.compile("^ami-.*")
        commit_hash_regex = re.compile("[0-9a-f]{40}")

        build_date_value = latest_build_info['build_date']
        ami_id = list(filter(ami_id_regex.match, output_list))[0]
        commit_hash = list(filter(commit_hash_regex.match, output_list))[0]

        key_names = ["build_date", "ami_id", "commit_hash"]
        payload_response_content = [build_date_value, ami_id, commit_hash]
        return dict((key, value) for (key, value) in zip(key_names, payload_response_content))

parser = api.parser()
parser.add_argument('payload', type=list, help='JSON payload', location='json')

# Response model for latest build endpoint
response_model = api.model('LatestAMIBuild', {
    'build_date': fields.Integer(readOnly=True, required=True, description='Build date'),
    'ami_id': fields.String(readOnly=True, required=True, description='AMI ID'),
    'commit_hash': fields.String(readOnly=True, required=True, description='SHA1 Commit ID')
})

# Health check endpoint
health = HealthCheck()
def api_ok():
    return True, "API OK"

health.add_check(api_ok)
app.add_url_rule("/health", "healthcheck", view_func=lambda: health.run())

# Endpoint for returning latest build
@api.route('/builds')
class LatestAMIBuildInfo(Resource):
    @api.doc('query_latest_build')
    @api.expect(parser)
    @api.marshal_with(response_model, code=200)
    def post(self):
        return AMIBuildInfo(api.payload).latest_build_data()

# Run the app
if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=80)
