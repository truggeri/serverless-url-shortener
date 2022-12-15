require 'pry'
require_relative '../src/short'

RSpec.describe "Short" do
  before do
    allow(SecureRandom).to receive(:uuid).and_return(given_uuid)
  end

  let(:given_short) { 'pets' }
  let(:given_full)  { 'https://www.petfinder.com' }
  let(:time)        { '2021-06-23 10:31:00' }
  let(:given_uuid)  { '31169afe-b08b-43dc-8edd-fbdc65df2cd1' }
  let(:short)       { Timecop.freeze(time) { Short.new(given_short, given_full) } }

  describe 'to_s' do
    subject { short.to_s }

    it 'jsonifys data' do
      expected = '{"short_url":"pets","full_url":"https://www.petfinder.com",' \
                 '"created_at":"2021-06-23T17:31:00Z","token":"eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.' \
                 'eyJpYXQiOjE2MjQ0Njk0NjAsImlzcyI6InNlcnZlcmxlc3Mtc2hvcnQiLCJ1dWlkIjoiMzExNjlhZmUtYj' \
                 'A4Yi00M2RjLThlZGQtZmJkYzY1ZGYyY2QxIn0.KV6xQUUDoFWghCP3lTG563UouUzmDZLUES5KZ5vX6tA"}'
      expect(subject).to eq(expected)
    end
  end

  describe 'to_h' do
    subject { short.to_h }

    it 'hashes data' do
      expect(subject).to match({
        'pk' => given_short,
        'full_url' => given_full,
        'created_at' => '2021-06-23T17:31:00Z',
        'user_generated' => true,
        'uuid' => given_uuid
      })
    end
  end

  describe 'valid' do
    describe 'short' do
      subject { short.valid? }

      context 'when too short' do
        let(:given_short) { 'abc' }

        it { expect(subject).to eq(false) }
      end

      context 'when too long' do
        let(:given_short) { 'abcllksdjflksjdfklsjdflkjsdlkfjsdlkfjsldkfjskldjfskldjfsnvsiudgnvwefoihnsoifnsoifndoifnsdoifnfnsdfoin' }

        it { expect(subject).to eq(false) }
      end

      context 'when reserved' do
        let(:given_short) { 'admin' }

        it { expect(subject).to eq(false) }
      end

      context 'when invalid char used' do
        let(:given_short) { 'AbC123-_.' }

        it { expect(subject).to eq(false) }
      end

      context 'when valid' do
        let(:given_short) { 'AbC123-_' }

        it { expect(subject).to eq(true) }
      end
    end

    describe 'full' do
      subject { short.valid? }

      context 'when too short' do
        let(:given_full) { 'ab' }

        it { expect(subject).to eq(false) }
      end

      context 'when too long' do
        let(:given_full) { 'abcllksdjflksjdfklsjdflkjsdlkfjsdlkfjsldkfjskldjfskldjfsnvsiudgnvwefoihnsoifnsoifndoifnsdoifnfnsdfoin' }

        it { expect(subject).to eq(false) }
      end

      context 'when invalid char used' do
        let(:given_full) { '<script>' }

        it { expect(subject).to eq(false) }
      end

      context 'when valid' do
        let(:given_full) { 'https://www.petfinder.com/?mode=test#header' }

        it { expect(subject).to eq(true) }
      end
    end
  end
end
