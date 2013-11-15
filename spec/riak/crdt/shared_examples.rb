shared_examples_for "Map CRDT" do
  let(:typed_collection){ Riak::Crdt::TypedCollection }

  it 'should contain counters' do
    expect(subject).to respond_to(:counters)
    expect(subject.counters).to be_an_instance_of typed_collection
  end
  
  it 'should contain flags' do
    expect(subject).to respond_to(:flags)
    expect(subject.counters).to be_an_instance_of typed_collection
  end
  
  it 'should contain maps' do
    expect(subject).to respond_to(:maps)
    expect(subject.counters).to be_an_instance_of typed_collection
  end
  
  it 'should contain registers' do
    expect(subject).to respond_to(:registers)
    expect(subject.counters).to be_an_instance_of typed_collection
  end
  
  it 'should contain sets' do
    expect(subject).to respond_to(:sets)
    expect(subject.counters).to be_an_instance_of typed_collection
  end
end

shared_examples_for "Counter CRDT" do
  it 'should have a value' do
    expect(subject.value).to be_an ::Integer
    expect(subject.to_i).to eq subject.value
  end
  
  it 'should have an increment method' do
    expect(subject).to respond_to :increment
  end

  it 'should have a decrement method' do
    expect(subject).to respond_to :decrement
  end
end
