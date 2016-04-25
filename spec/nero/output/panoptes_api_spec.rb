require 'spec_helper'

describe Nero::Output::PanoptesApi do
  subject(:api) { described_class.new("http://example.org", "key", "secret") }

  before do
    stub_request(:post, "http://example.org/oauth/token")
      .with(body: {"client_id" => "key", "client_secret" => "secret", "grant_type" => "client_credentials"},
            headers: {'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Faraday v0.9.2'})
      .to_return(status: 200,
                 body: '{"access_token":"token", "token_type":"bearer", "expires_in":7200, "scope":"public user project group collection classification subject medium", "created_at":1449498104}',
                 headers: {'Content-Type' => 'application/json; charset=utf-8'})
  end

  describe '#retire' do
    let(:subject_state) { double(workflow_id: 1, subject_id: 1) }

    it 'retires subjects' do
      request = stub_request(:post, "http://example.org/api/workflows/1/retired_subjects")
        .to_return(status: 200, body: '')
      api.retire(subject_state)
      expect(request).to have_been_requested
    end

    it 'raises an error if panoptes responds with something other than HTTP 200 status' do
      stub_request(:post, "http://example.org/api/workflows/1/retired_subjects")
        .to_return(status: 500, body: '')
      expect { api.retire(subject_state) }.to raise_error(Panoptes::Client::ServerError)
    end
  end
end
