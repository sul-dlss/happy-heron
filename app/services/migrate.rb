# run via:
#  bin/rails r "Migrate.run"

class Migrate
    DATA = <<~EOF
        DRUID,DOI,H2 collection id,license,worktype,deposit created,depositor,subtype
        sq987cc0358,10.25740/sq987cc0358,168,CC-BY-SA-3.0,data,"April 26, 2021",amw579 ,
        jx921pv3255,10.25740/jx921pv3255,168,CC-BY-3.0,text,"May 20, 2021",shenoy,technical report
        bd095jt2882,10.25740/bd095jt2882,120,CC-BY-3.0,data,"February 07, 2019",ccosner,
        bg095cp1548,10.25740/bg095cp1548,168,CC-BY-SA-3.0,data,"June 13, 2019",asharpe1 ,
        ct379mv1537,10.25740/ct379mv1537,202,CC-BY-NC-ND-3.0,data,"November 10, 2020",aboehm ,
        dz692fn7184,10.25740/dz692fn7184,168,CC-BY-NC-SA-3.0,data,"January 15, 2020",tpark94 ,
        fb148fk5108,10.25740/fb148fk5108,130,ODC-By-1.0,data,"March 29, 2019",kcasciot ,
        gs834tz9068,10.25740/gs834tz9068,128,ODC-By-1.0,text,"August 29, 2020",jbrad ,article
        jb294tg1139,10.25740/jb294tg1139,59,CC-BY-NC-3.0,text,"April 30, 2019",mburnett ,thesis
        jm289gm4861,10.25740/jm289gm4861,168,CC-BY-NC-3.0,data,"December 02, 2020",mosszhao ,
        jr540cb6284,10.25740/jr540cb6284,66,CC-BY-3.0,text,"June 23, 2020",raymondg ,thesis
        ks811bm4485,10.25740/ks811bm4485,127,CC-BY-SA-3.0,text,"March 29, 2019",endy,technical report
        pj162xx4010,10.25740/pj162xx4010,58,CC-BY-NC-3.0,text,"January 06, 2020",mburnett,thesis
        ps529zk1425,10.25740/ps529zk1425,168,ODC-By-1.0,data,"February 20, 2020",hpfau ,
        px092px3282,10.25740/px092px3282,168,ODC-By-1.0,data,"August 20, 2020",nicogaut ,
        qs993pr7111,10.25740/qs993pr7111,202,no license,data,"February 08, 2020",aboehm ,
        rq831rt1470,10.25740/rq831rt1470,5,CC-BY-NC-3.0,data,"March 26, 2020",lime ,
        sc417ft5944,10.25740/sc417ft5944,168,ODC-By-1.0,data,"January 26, 2021",agau,
        tb877wd0973,10.25740/tb877wd0973,168,MPL-2.0,software/code,"February 18, 2021",eroosli ,
        tk375mb4283,10.25740/tk375mb4283,202,CC-BY-NC-3.0,data,"March 02, 2021",aboehm,
        vg665fp4193,10.25740/vg665fp4193,168,CC-BY-NC-ND-3.0,software/code,"October 05, 2020",sangst ,
        wg432jy0214,10.25740/wg432jy0214,168,ODC-By-1.0,data,"March 17, 2021",tworasar ,
        yn042kx5009,10.25740/yn042kx5009,202,CC-BY-NC-3.0,data,"April 30, 2021",aboehm ,
    EOF

    require 'csv'

    def self.run
        csv = CSV.parse(DATA, headers: true)
        owner = User.find_by!(email: "amyhodge@stanford.edu")

        csv.each do |row|
            sunetid = row['depositor'].strip
            depositor = User.find_or_create_by(email: "#{sunetid}@stanford.edu")
            work = Work.create!(druid: "druid:#{row['DRUID']}", depositor: depositor, owner: owner,
                               collection_id: row['H2 collection id'],
                               doi: row['DOI'])
            version = work.create_head(license: row['license'],
                                       work_type: row['worktype'],
                                       work: work, state: 'deposited')
            work.created_at = row['deposit created'].in_time_zone('Pacific Time (US & Canada)')
            work.save!
            puts work.id
        end
    end
end