require "simplygenius/atmos/commands/plan"

module SimplyGenius
  module Atmos
    module Commands

      describe Plan do

        let(:cli) { described_class.new("") }

        around(:each) do |ex|
          within_construct do |c|
            c.file('config/atmos.yml')
            Atmos.config = Config.new("ops")
            ex.run
            Atmos.config = nil
          end
        end

        describe "execute" do

          it "calls terraform with auto modules by default" do
            env = Hash.new
            te = TerraformExecutor.new(env)
            expect(Atmos.config.provider.auth_manager).to receive(:authenticate).and_yield(env)
            expect(TerraformExecutor).to receive(:new).
                with(process_env: env, working_group: 'default').and_return(te)
            expect(te).to receive(:run).with("plan", get_modules: true)
            cli.run([])
          end

          it "calls terraform without auto modules if configured" do
            env = Hash.new
            te = TerraformExecutor.new(env)
            expect(Atmos.config.provider.auth_manager).to receive(:authenticate).and_yield(env)
            expect(TerraformExecutor).to receive(:new).
                with(process_env: env, working_group: 'default').and_return(te)
            Atmos.config.instance_variable_get(:@config).notation_put("atmos.terraform.disable_auto_modules", true)
            expect(te).to receive(:run).with("plan", get_modules: false)
            cli.run([])
          end

        end

      end

    end
  end
end
