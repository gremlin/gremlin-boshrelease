require 'json'
require 'rspec'
require 'rspec/bash'
require 'bosh/template/test'
require 'pathname'
require 'fileutils'


describe 'gremlind release' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '../..')) }
  let(:stubbed_env) { Rspec::Bash::StubbedEnv.new(Rspec::Bash::StubbedEnv::BASH_STUB) }

  describe 'gremlind job' do
    let(:job) { release.job('gremlind') }

    describe 'pre-start' do
      let(:template) { job.template('bin/pre-start') }

      describe 'render' do
        let(:manifest) do
          {
            'gremlind' => {
              'environmentid' => 'environmentid',
              'apitoken' => 'apitoken'
            }
          }
        end

        it 'render' do
          script = template.render(manifest)

          expect(script).to match('^export GREMLIN_IDENTIFIER=""$')
          expect(script).to match('^export GREMLIN_SERVICE_URL=""$')
          expect(script).to match('^export GREMLIN_TEAM_ID=""$')
          expect(script).to match('^export GREMLIN_TEAM_SECRET"a"$')
        end
      end

      describe 'install base dir #1' do
        describe 'test directory exists' do
          let(:manifest) do
            {
              'gremlind' => {
                'environmentid' => 'environmentid',
                'apitoken' => 'apitoken'
              }
            }
          end
          it 'test' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(stdout).to match("Not enough disk space available on /var/vcap/data!")
            expect(status.exitstatus).to eq 1
          end
        end
        describe 'create install base dir' do
          it 'make path', :install => true do
            FileUtils.mkpath('/var/vcap/data')
          end
        end
      end

      describe 'custom urls' do
        describe 'downloadurl' do
          let(:manifest) do
            {
              'gremlind' => {
                'downloadurl' => 'downloadurl',
                'environmentid' => '',
                'apitoken' => ''
              }
            }
          end
          it 'exec' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(stdout).to match(/Downloading agent installer from downloadurl/)
            expect(stdout).to match(/Dynatrace agent download failed, retrying in /)
            expect(stdout).to match(/ERROR: Downloading agent installer failed!/)
            expect(status.exitstatus).to eq 1
          end
        end
        describe 'apiurl' do
          let(:manifest) do
            {
              'gremlind' => {
                'apiurl' => 'apiurl',
                'environmentid' => 'na',
                'apitoken' => 'na'
              }
            }
          end
          it 'exec' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(stdout).to include("Downloading agent installer from apiurl/v1/deployment/installer/agent/unix/default/latest?Api-Token=na")
            expect(stdout).to match(/ERROR: Downloading agent installer failed!/)
            expect(status.exitstatus).to eq 1
          end
        end
      end

      describe 'invalid configuration' do
        describe 'no environmentid' do
          let(:manifest) do
            {
              'gremlind' => {
                'environmentid' => '',
                'apitoken' => 'apitoken'
              }
            }
          end
          it 'exec' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(status.exitstatus).to eq 1
            expect(stdout).to match(/Please set environment ID and API token for Dynatrace OneAgent./)
          end
        end
        describe 'no apitoken' do
          let(:manifest) do
            {
              'gremlind' => {
                'environmentid' => 'environmentid',
                'apitoken' => ''
              }
            }
          end
          it 'exec' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(status.exitstatus).to eq 1
            expect(stdout).to match(/Please set environment ID and API token for Dynatrace OneAgent./)
          end
        end
        describe 'no environmentid,apitoken' do
          let(:manifest) do
            {
              'gremlind' => {
                'environmentid' => '',
                'apitoken' => ''
              }
            }
          end
          it 'exec' do
            script = template.render(manifest)
            stdout, stderr, status = stubbed_env.execute_inline(script)
            expect(status.exitstatus).to eq 1
            expect(stdout).to match(/Please set environment ID and API token for Dynatrace OneAgent./)
          end
        end
      end

      describe 'install' do
        let(:manifest) do
          {
            'gremlind' => {
              'environmentid' => ENV["DT_TENANT"],
              'apitoken' => ENV["DT_API_TOKEN"],
              'apiurl' => ENV["DT_API_URL"]
            }
          }
        end
        it 'parameter test' do
          expect(ENV).to have_key("DT_TENANT")
          expect(ENV).to have_key("DT_API_TOKEN")
          expect(ENV).to have_key("DT_API_URL")
        end
        it 'exec', :install => true do
          script = template.render(manifest)
          stdout, stderr, status = stubbed_env.execute_inline(script)
          expect(stdout).to match(/Installation finished/)
          expect(stdout).to_not match(/Error/)
          expect(status.exitstatus).to eq 0
          expect(FileTest.exist?('/var/vcap/sys/run/gremlind/gremlind-watchdog.pid')).to be true
        end
      end

    end

    describe 'stop-gremlind.sh', :monit => true do
      let(:template) { job.template('bin/stop-gremlind.sh') }
      let(:manifest) {}
      it 'exec' do
        script = template.render(manifest)
        stdout, stderr, status = stubbed_env.execute_inline(script)
        expect(status.exitstatus).to eq 0
      end
    end


    describe 'start-gremlind.sh', :monit => true do
      let(:template) { job.template('bin/start-gremlind.sh') }
      let(:manifest) {}
      it 'exec' do
        script = template.render(manifest)
        stdout, stderr, status = stubbed_env.execute_inline(script)
        expect(status.exitstatus).to eq 0
      end
    end

  end
end
