# encoding: utf-8
require 'spec_helper'

describe PoParser::Entry do
  before(:each) do
    @entry = PoParser::Entry.new
    @entry.msgid = 'some string'
  end

  let(:labels) do
    [:refrence, :extracted_comment, :flag, :previous_untraslated_string,
      :translator_comment, :msgid, :msgid_plural, :msgstr, :msgctxt]
  end

  it 'should respond to labels' do
    labels.each do |label|
      expect(@entry).to respond_to label
    end
  end

  it 'should raise error if lable is unknown' do
    expect {
      PoParser::Entry.new({:msgstr => 'test', :blah_blah => 'error'})
    }.to raise_error(ArgumentError, "Unknown label blah_blah")
  end

  it 'should show a hash presentation of a entry' do
    @entry.msgid = 'string'
    @entry.msgstr = 'reshte'
    expect(@entry.to_h).to eq({:msgid=>"string", :msgstr=>"reshte"})
  end

  it 'should translate the entry' do
    @entry.translate ('this entry is translated')
    expect(@entry.msgstr.to_s).to eq 'this entry is translated'
  end

  it 'checks if the entry is translated' do
    expect(@entry.translated?).to be_falsy
    @entry.translate ''
    expect(@entry.translated?).to be_falsy
    @entry.translate 'translated'
    expect(@entry.complete?).to be_truthy
  end

  context 'Plural' do
    it 'returns false if it\'s not plural' do
      expect(@entry.plural?).to be_falsy
    end

    it 'returns true if it\'s plural' do
      @entry.msgid_plural = 'sth'
      expect(@entry.plural?).to be_truthy
    end
  end

  context 'Flags' do
    it 'should check if a entry is fuzzy' do
      expect(@entry.fuzzy?).to be_falsy
      @entry.flag = 'fuzzy'
      expect(@entry.fuzzy?).to be_truthy
    end

    it 'should flag a entry as fuzzy' do
      expect(@entry.flag_as_fuzzy).to be_truthy
      expect(@entry.flag).to eq('fuzzy')
    end

    it 'should be able to set a custome flag' do
      expect(@entry.flag_as 'python-format').to be_truthy
      expect(@entry.flag).to eq('python-format')
    end
  end

  context 'Convertion to string' do
    it 'should be able to show string representaion of entries' do
      @entry.flag = 'fuzzy'
      @entry.msgid = 'string'
      @entry.msgstr = 'reshte'
      result = "#, fuzzy\nmsgid \"string\"\nmsgstr \"reshte\"\n"
      expect(@entry.to_s).to eq result
    end

    it 'convert multiline entries to string' do
      @entry.flag = 'fuzzy'
      @entry.msgid = ['first line', 'second line']
      @entry.msgstr = ['first line', 'second line']
      result = "#, fuzzy\nmsgid \"\"\n\"first line\"\n\"second line\"\nmsgstr \"\"\n\"first line\"\n\"second line\"\n"
      expect(@entry.to_s).to eq(result)
    end
  end

  context 'Cached' do
    before do
      @entry = PoParser::Entry.new
      @entry.cached = '#~ msgid "a cached entry"'
      @entry.flag = 'Fuzzy'
    end

    it 'checks for chached entries' do
      expect(@entry.cached?).to be_truthy
    end

    it 'shouldn be counted as untranslated' do
      expect(@entry.untranslated?).to be_falsy
    end

    it 'shouldn be counted as translated' do
      expect(@entry.translated?).to be_falsy
    end

    it 'shouldn\'t mark it as fuzzy' do
      expect(@entry.fuzzy?).to be_falsy
    end
  end
end
