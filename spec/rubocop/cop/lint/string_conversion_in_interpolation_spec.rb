# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::StringConversionInInterpolation do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects `to_s` in interpolation' do
    expect_offense(<<~'RUBY')
      "this is the #{result.to_s}"
                            ^^^^ Redundant use of `Object#to_s` in interpolation.
      /regexp #{result.to_s}/
                       ^^^^ Redundant use of `Object#to_s` in interpolation.
      :"symbol #{result.to_s}"
                        ^^^^ Redundant use of `Object#to_s` in interpolation.
      `backticks #{result.to_s}`
                          ^^^^ Redundant use of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "this is the #{result}"
      /regexp #{result}/
      :"symbol #{result}"
      `backticks #{result}`
    RUBY
  end

  it 'registers an offense and corrects `to_s` in an interpolation ' \
    'with several expressions' do
    expect_offense(<<~'RUBY')
      "this is the #{top; result.to_s}"
                                 ^^^^ Redundant use of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "this is the #{top; result}"
    RUBY
  end

  it 'accepts #to_s with arguments in an interpolation' do
    expect_no_offenses('"this is a #{result.to_s(8)}"')
  end

  it 'accepts interpolation without #to_s' do
    expect_no_offenses('"this is the #{result}"')
  end

  it 'registers an offense and corrects an implicit receiver' do
    expect_offense(<<~'RUBY')
      "#{to_s}"
         ^^^^ Use `self` instead of `Object#to_s` in interpolation.
    RUBY

    expect_correction(<<~'RUBY')
      "#{self}"
    RUBY
  end

  it 'does not explode on empty interpolation' do
    expect_no_offenses('"this is #{} silly"')
  end
end
