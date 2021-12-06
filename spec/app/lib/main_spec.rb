require 'spec_helper'

RSpec.describe Main do
  describe 'searched path' do
    before do
      FoldersWithMusic.any_instance.stubs(names: [])
      Actions::FixedFolder.any_instance.stubs(:update!)
    end

    context 'with given path' do
      let(:tested_folder) { 'test/fol_der' }

      it 'searches given path' do
        Dir.expects(:chdir).with(tested_folder)

        Main.new(tested_folder).process
      end
    end

    context 'without given path' do
      it "searches user's desktop" do
        Dir.expects(:chdir).with("/Users/#{ENV['USER']}/Desktop")

        Main.new(nil).process
      end
    end
  end
end
