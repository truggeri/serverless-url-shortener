require_relative '../src/token'

RSpec.describe Token do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('JWT_SECRET').and_return('a-secret')
  end

  describe 'decode' do
    subject { Token.decode(token) }

    context 'when token is nil' do
      let(:token) { nil }

      it { expect(subject).to eq(nil) }
    end

    context 'when token is not a jws' do
      let(:token) { 'lsjflksfsdf' }

      it { expect(subject).to eq(nil) }
    end

    context 'when token is junk jws' do
      let(:token) { 'a.b.c' }

      it { expect(subject).to eq(nil) }
    end

    context 'when token is good' do
      let(:token) do
        'eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.' \
        'eyJpYXQiOjE2MjQ0Njk0NjAsImlzcyI6InNlcnZlcmxlc3Mtc2hvcnQiLCJmb28iOiJiYXIifQ.' \
        'laT8sO0nRoZsGwmOwnpTqDgAAZwUQkc5GdEx_Hs2nkw'
      end

      it 'gives expected payload' do
        expect(subject).to include('foo' => 'bar', 'iat' => 1_624_469_460, 'iss' => Token::ISSUER)
      end
    end
  end

  describe 'encode' do
    subject { Token.encode(payload) }

    context 'when payload is nil' do
      let(:payload) { nil }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when payload is a string' do
      let(:payload) { 'a string' }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when payload is a hash' do
      let(:payload) { { foo: :bar } }
      let(:time)    { '2021-06-23 10:31:00' }

      it 'generates token' do
        expected = 'eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.' \
                   'eyJpYXQiOjE2MjQ0Njk0NjAsImlzcyI6InNlcnZlcmxlc3Mtc2hvcnQiLCJmb28iOiJiYXIifQ.' \
                   'laT8sO0nRoZsGwmOwnpTqDgAAZwUQkc5GdEx_Hs2nkw'
        Timecop.freeze(time) { expect(subject).to eq(expected) }
      end
    end
  end
end
