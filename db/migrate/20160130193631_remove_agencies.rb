# class RemoveAgencies < ActiveRecord::Migration
# 	def up
# 		# drop_table :agencies
# 		drop_table :article_agencies
# 	end

# 	def down
#     # create_table :agencies do |t|
#     #   t.string :name
#     #   t.integer :state_id
#     #   t.string :state

#     #   t.timestamps null: false
#     # end

#     create_table :article_agencies do |t|
#       t.integer :article_id
#       t.integer :agency_id

#       t.timestamps null: false
#     end
# 	end
# end
