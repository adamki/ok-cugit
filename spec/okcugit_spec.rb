require 'okcugit'

RSpec.describe Okcugit do
  it 'gives me the contributor names for a given github repo' do
    contributors = Okcugit.contributors_for('JoshCheek/rack-josh')
    expect(contributors).to include Okcugit::Contributor.new(name: 'Josh Cheek', email: 'josh.cheek@gmail.com')
  end

  it 'only shows each contributor once, and they are given in alphabetical order' do
    known_contributor_names = /Horace Williams|Jason Noble|Jeff Casimir|Jeff Casimir|Josh Cheek|Josh Mejia|Lori Culberson|Lovisa Svallingson|Michael Dao|Rachel Warbelow|Samson Brock|Trey Tomlinson/
    contributors            = Okcugit.contributors_for('turingschool/challenges')
    name_email_pairs        = contributors.map { |c| [c.name, c.email] }
    expect(name_email_pairs.uniq.length).to eq name_email_pairs.length

    names = contributors.map(&:name).grep(known_contributor_names)
    expect(names).to eq [
      'Horace Williams',
      'Jason Noble',
      'Jeff Casimir',
      'Jeff Casimir',
      'Josh Cheek',
      'Josh Mejia',
      'Lori Culberson',
      'Lovisa Svallingson',
      'Michael Dao',
      'Rachel Warbelow',
      'Samson Brock',
      'Trey Tomlinson',
    ]
  end
end
