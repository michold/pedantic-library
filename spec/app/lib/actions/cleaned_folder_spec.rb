# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Actions::CleanedFolder do
  around do |example|
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        @temp_dir = temp_dir
        example.run
      end
    end
  end

  describe '#update!' do
    let(:tested_dir) { 'tested_dir' }

    before do
      FileUtils.mkdir(tested_dir) unless File.directory?(tested_dir)
    end

    context 'with files to remove' do
      before do
        FileUtils.touch("#{tested_dir}/.DS_STORE")
        FileUtils.touch("#{tested_dir}/test.dat")
        FileUtils.touch("#{tested_dir}/Thumbs.db")
      end

      context 'remove accepted' do
        before do
          Cli::Approval.stubs(gets: "y\n")
        end

        it 'removes .DS_STORE files' do
          described_class.new(tested_dir).update!
          expect(Dir.entries(tested_dir)).not_to include('.DS_STORE')
        end

        it 'removes .dat files' do
          described_class.new(tested_dir).update!
          expect(Dir.entries(tested_dir)).not_to include('test.dat')
        end

        it 'removes thumbs files' do
          described_class.new(tested_dir).update!
          expect(Dir.entries(tested_dir)).not_to include('Thumbs.db')
        end

        context 'files in subdir' do
          before do
            FileUtils.mkdir("#{tested_dir}/subdir")
            FileUtils.touch("#{tested_dir}/subdir/.DS_STORE")
          end

          it 'removes them too' do
            described_class.new(tested_dir).update!
            expect(Dir.entries("#{tested_dir}/subdir")).not_to include('.DS_STORE')
          end
        end
      end

      context 'remove declined' do
        before do
          Cli::Approval.stubs(gets: "\n")
        end

        it "doesn't remove the files" do
          described_class.new(tested_dir).update!
          expect(Dir.entries(tested_dir)).to include('.DS_STORE')
        end
      end
    end

    context 'with no files to remove' do
      before do
        FileUtils.touch("#{tested_dir}/dont_touch_me")
      end

      it 'still works' do
        described_class.new(tested_dir).update!
        expect(Dir.entries(tested_dir)).to include 'dont_touch_me'
      end
    end
  end
end
