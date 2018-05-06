# frozen_string_literal: true

#
# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
if State.count.zero?
  puts 'Creating States...'
  states =
    [
      { ansi_code: 'AL', iso: 'US-AL', name: 'Alabama' },
      { ansi_code: 'AK', iso: 'US-AK', name: 'Alaska' },
      { ansi_code: 'AZ', iso: 'US-AZ', name: 'Arizona' },
      { ansi_code: 'AR', iso: 'US-AR', name: 'Arkansas' },
      { ansi_code: 'CA', iso: 'US-CA', name: 'California' },
      { ansi_code: 'CO', iso: 'US-CO', name: 'Colorado' },
      { ansi_code: 'CT', iso: 'US-CT', name: 'Connecticut' },
      { ansi_code: 'DE', iso: 'US-DE', name: 'Delaware' },
      { ansi_code: 'DC', iso: 'US-DC', name: 'District of Columbia' },
      { ansi_code: 'FL', iso: 'US-FL', name: 'Florida' },
      { ansi_code: 'GA', iso: 'US-GA', name: 'Georgia' },
      { ansi_code: 'HI', iso: 'US-HI', name: 'Hawaii' },
      { ansi_code: 'ID', iso: 'US-ID', name: 'Idaho' },
      { ansi_code: 'IL', iso: 'US-IL', name: 'Illinois' },
      { ansi_code: 'IN', iso: 'US-IN', name: 'Indiana' },
      { ansi_code: 'IA', iso: 'US-IA', name: 'Iowa' },
      { ansi_code: 'KS', iso: 'US-KS', name: 'Kansas' },
      { ansi_code: 'KY', iso: 'US-KY', name: 'Kentucky' },
      { ansi_code: 'LA', iso: 'US-LA', name: 'Louisiana' },
      { ansi_code: 'ME', iso: 'US-ME', name: 'Maine' },
      { ansi_code: 'MD', iso: 'US-MD', name: 'Maryland' },
      { ansi_code: 'MA', iso: 'US-MA', name: 'Massachusetts' },
      { ansi_code: 'MI', iso: 'US-MI', name: 'Michigan' },
      { ansi_code: 'MN', iso: 'US-MN', name: 'Minnesota' },
      { ansi_code: 'MS', iso: 'US-MS', name: 'Mississippi' },
      { ansi_code: 'MO', iso: 'US-MO', name: 'Missouri' },
      { ansi_code: 'MT', iso: 'US-MT', name: 'Montana' },
      { ansi_code: 'NE', iso: 'US-NE', name: 'Nebraska' },
      { ansi_code: 'NV', iso: 'US-NV', name: 'Nevada' },
      { ansi_code: 'NH', iso: 'US-NH', name: 'New Hampshire' },
      { ansi_code: 'NJ', iso: 'US-NJ', name: 'New Jersey' },
      { ansi_code: 'NM', iso: 'US-NM', name: 'New Mexico' },
      { ansi_code: 'NY', iso: 'US-NY', name: 'New York' },
      { ansi_code: 'NC', iso: 'US-NC', name: 'North Carolina' },
      { ansi_code: 'ND', iso: 'US-ND', name: 'North Dakota' },
      { ansi_code: 'OH', iso: 'US-OH', name: 'Ohio' },
      { ansi_code: 'OK', iso: 'US-OK', name: 'Oklahoma' },
      { ansi_code: 'OR', iso: 'US-OR', name: 'Oregon' },
      { ansi_code: 'PA', iso: 'US-PA', name: 'Pennsylvania' },
      { ansi_code: 'RI', iso: 'US-RI', name: 'Rhode Island' },
      { ansi_code: 'SC', iso: 'US-SC', name: 'South Carolina' },
      { ansi_code: 'SD', iso: 'US-SD', name: 'South Dakota' },
      { ansi_code: 'TN', iso: 'US-TN', name: 'Tennessee' },
      { ansi_code: 'TX', iso: 'US-TX', name: 'Texas' },
      { ansi_code: 'UT', iso: 'US-UT', name: 'Utah' },
      { ansi_code: 'VT', iso: 'US-VT', name: 'Vermont' },
      { ansi_code: 'VA', iso: 'US-VA', name: 'Virginia' },
      { ansi_code: 'WA', iso: 'US-WA', name: 'Washington' },
      { ansi_code: 'WV', iso: 'US-WV', name: 'West Virginia' },
      { ansi_code: 'WI', iso: 'US-WI', name: 'Wisconsin' },
      { ansi_code: 'WY', iso: 'US-WY', name: 'Wyoming' },
      { ansi_code: 'AB', iso: 'CA-AB', name: 'Alberta' },
      { ansi_code: 'BC', iso: 'CA-BC', name: 'British Columbia' },
      { ansi_code: 'MB', iso: 'CA-MB', name: 'Manitoba' },
      { ansi_code: 'NB', iso: 'CA-NB', name: 'New Brunswick' },
      { ansi_code: 'NL', iso: 'CA-NL', name: 'Newfoundland and Labrador' },
      { ansi_code: 'NS', iso: 'CA-NS', name: 'Nova Scotia' },
      { ansi_code: 'ON', iso: 'CA-ON', name: 'Ontario' },
      { ansi_code: 'PE', iso: 'CA-PE', name: 'Prince Edward Island' },
      { ansi_code: 'QC', iso: 'CA-QC', name: 'Quebec' },
      { ansi_code: 'SK', iso: 'CA-SK', name: 'Saskatchewan' },
      { ansi_code: 'NT', iso: 'CA-NT', name: 'Northwest Territories' },
      { ansi_code: 'NU', iso: 'CA-NU', name: 'Nunavut' },
      { ansi_code: 'YT', iso: 'CA-YT', name: 'Yukon Territory' }
    ]
  total = states.length.to_f
  process_counter = 0
  process_display = 0
  states.each do |state|
    State.create(state)
    process_counter += 1
    percent = ((process_counter / total) * 100).round(1)
    display = case process_display
              when 0
                process_display += 1
                '|'
              when 1
                process_display += 1
                '/'
              when 2
                process_display += 1
                '-'
              when 3
                process_display += 1
                '|'
              when 4
                process_display += 1
                '-'
              when 5
                process_display = 0
                '\\'
              end
    print '\r\r Creating states #{percent}% #{display}'
  end
end

if Gender.count.zero?
  puts 'Creating Genders...'

  genders = [
    ['Male'],
    ['Female'],
    ['Transgender'],
    [' -- '],
    ['Agender'],
    ['Androgyne'],
    ['Androgynous'],
    ['Bigender'],
    ['Cis'],
    ['Cisgender'],
    ['Cis Female'],
    ['Cis Male'],
    ['Cis Man'],
    ['Cis Woman'],
    ['Cisgender Female'],
    ['Cisgender Male'],
    ['Cisgender Man'],
    ['Cisgender Woman'],
    ['Female to Male'],
    ['FTM'],
    ['Gender Fluid'],
    ['Gender Nonconforming'],
    ['Gender Questioning'],
    ['Gender Variant'],
    ['Genderqueer'],
    ['Intersex'],
    ['Male to Female'],
    ['MTF'],
    ['Neither'],
    ['Neutrois'],
    ['Non-binary'],
    ['Other'],
    ['Pangender'],
    ['Trans'],
    ['Trans*'],
    ['Trans Female'],
    ['Trans* Female'],
    ['Trans Male'],
    ['Trans* Male'],
    ['Trans Man'],
    ['Trans* Man'],
    ['Trans Person'],
    ['Trans* Person'],
    ['Trans Woman'],
    ['Trans* Woman'],
    ['Transfeminine'],
    ['Transgender'],
    ['Transgender Female'],
    ['Transgender Male'],
    ['Transgender Man']
  ]

  genders.each do |gender|
    Gender.create(sex: gender[0])
  end
end

if Ethnicity.count.zero?
  puts 'Creating Ethnicities...'
  ethnicities = [
    ['Black'],
    ['White'],
    ['Hispanic'],
    ['Native American'],
    ['Asian'],
    ['Arabic']
  ]

  ethnicities.each do |ethnicity|
    Ethnicity.create(title: ethnicity[0])
  end
end

if User.count.zero?
    puts 'Creating Users...'

    users = [
      { name: 'John Doe',
        email: 'jdoe@example.com',
        password: 'password',
        password_confirmation: 'password',
        admin: true },
      { name: 'Jane Smith',
        email: 'jsmith@example.com',
        password: 'password',
        password_confirmation: 'password' },
      { name: 'Jan Alleman',
        email: 'jalleman@example.com',
        password: 'password',
        password_confirmation: 'password' },
      {name: 'Zhang San',
        email: 'szhang@example.com',
        password: 'password',
        password_confirmation: 'password' }
    ]

    users.each do |user|
      User.create(user)
    end
end

if Case.count.zero?
  puts 'Creating Cases...'

  cases = [
    { title: 'Sven Svensson',
      date: '01/10/2017',
      subjects_attributes: { '0' => { name: 'Sven Svensson',
                                      age: '25'
                                    }
                           },
      city: 'Houston',
      state: State.where(name: 'Texas').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Janez Novak',
      date: '02/10/2017',
      subjects_attributes: { '0' => { name: 'Janez Novak',
                                      age: '26'
                                    }
                           },
      city: 'Little Rock',
      state: State.where(name: 'Arkansas').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Janina Kowalska',
      date: '01/12/2011',
      subjects_attributes: { '0' => { name: 'Janina Kowalska',
                                      age: '35'
                                    }
                           },
      city: 'Boulder',
      state: State.where(name: 'Colorado').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Kari Holm',
      date: '11/05/2017',
      subjects_attributes: { '0' => { name: 'Kari Holm',
                                      age: '20'
                                    }
                           },
      city: State.where(name: 'Florida').first,
      state_id: '10',
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Jonas Petraitis',
      date: '31/10/2017',
      subjects_attributes: { '0' => { name: 'Jonas Petraitis',
                                      age: '56'
                                    }
                           },
      city: 'Boise',
      state_id: State.where(name: 'Idaho').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Manku Thimman',
      date: '17/03/1997',
      subjects_attributes: { '0' => { name: 'Manku Thimma',
                                      age: '33'
                                    }
                           },
      city: 'Gary',
      state_id: State.where(name: 'Indiana').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Mario Rossi',
      date: '21/11/2004',
      subjects_attributes: { '0' => { name: 'Mario Rossi',
                                      age: '31'
                                    }
                           },
      city: 'Louisville',
      state: State.where(name: 'Kentucky').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Max Mustermann',
      date: '11/05/2014',
      subjects_attributes: { '0' => { name: 'Max Mustermann',
                                      age: '25'
                                    }
                           },
      city: 'Amherst',
      state: State.where(name: 'Massachusetts').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Chichiko Bendeliani',
      date: '09/07/2009',
      subjects_attributes: { '0' => { name: 'Chichiko Bendeliani',
                                      age: '40'
                                    }
                           },
      city: 'St. Louis',
      state:  State.where(name: 'Missouri').first,
      overview: 'a',
      summary: 'Added a case' },

    { title: 'Sally Housecoat',
      date: '01/01/2001',
      subjects_attributes: { '0' => { name: 'Sally Housecoat',
                                      age: '39'
                                    }
                           },
      city: 'Houston',
      state_id: State.where(name: 'Texas').first,
      overview: 'a',
      summary: 'Added a case' }
  ]

  cases.each do |this_case|
    "Adding case #{this_case['title']}"
    Case.create(this_case)
  end
end

if Agency.count.zero?
  puts 'Creating Agencies...'

  agencies = [
    { name: 'City of Houston Police Department',
      city: 'Houston',
      state:  State.where(name: 'Texas').first },
    { name: 'City of Beaumont Police Department',
      city: 'Beaumont',
      state:  State.where(name: 'Texas').first }
  ]

  agencies.each do |agency|
    Agency.create(agency)
  end
end
