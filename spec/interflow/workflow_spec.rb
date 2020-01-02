class TestWorkFlow < Interflow::Workflow
  interactions :test_me, :fix_me, :make_me_fast, prefix: 'test'
end

RSpec.describe Interflow::Workflow do
  context 'at class level' do
    subject { TestWorkFlow }

    it 'has 3 registered interactions' do
      expect(subject.instance_variable_get(:@interactions).size).to eq 3
    end

    it 'has a prefix' do
      expect(subject.instance_variable_get(:@prefix)).to eq('test')
    end
  end

  context 'a new Workflow' do
    let(:ctx) { { thing: 1234 } }
    subject { TestWorkFlow.new(context: ctx) }

    it 'has the right context' do
      expect(subject.context).to eq(ctx)
    end

    context '#interactions' do
      let(:expected_intrxns) { %i(test_me fix_me make_me_fast) }
      it 'returns the registered interactions' do
        expect(subject.interactions).to include(*expected_intrxns)
      end
    end
  end
end
