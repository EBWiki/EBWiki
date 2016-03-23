class AddGenderDesignations < ActiveRecord::Migration
  @additional_designations = [
    [ "Agender" ],
    [ "Androgyne" ],
    [ "Androgynous" ],
    [ "Bigender" ],
    [ "Cis" ],
    [ "Cisgender" ],
    [ "Cis Female" ],
    [ "Cis Male" ],
    [ "Cis Man" ],
    [ "Cis Woman" ],
    [ "Cisgender Female" ],
    [ "Cisgender Male" ],
    [ "Cisgender Man" ],
    [ "Cisgender Woman" ],
    [ "Female to Male" ],
    [ "FTM" ],
    [ "Gender Fluid" ],
    [ "Gender Nonconforming" ],
    [ "Gender Questioning" ],
    [ "Gender Variant" ],
    [ "Genderqueer" ],
    [ "Intersex" ],
    [ "Male to Female" ],
    [ "MTF" ],
    [ "Neither" ],
    [ "Neutrois" ],
    [ "Non-binary" ],
    [ "Other" ],
    [ "Pangender" ],
    [ "Trans" ],
    [ "Trans*" ],
    [ "Trans Female" ],
    [ "Trans* Female" ],
    [ "Trans Male" ],
    [ "Trans* Male" ],
    [ "Trans Man" ],
    [ "Trans* Man" ],
    [ "Trans Person" ],
    [ "Trans* Person" ],
    [ "Trans Woman" ],
    [ "Trans* Woman" ],
    [ "Transfeminine" ],
    [ "Transgender Female" ],
    [ "Transgender Male" ],
    [ "Transgender Man" ]
  ]

  def self.up
    @additional_designations.each do |gender|
      Gender.create(:sex => gender[0])
    end
  end

  def self.down
    objs = Gender.where("id > 3")
    Gender.destroy(objs.flatten)
  end
end
