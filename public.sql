
--rename all tables to have names which are short and sensible

alter table "admin_point-l5_idn_mtb_population" rename to admin_point_l5;

alter table "admin_area-l3_idn_mbd" rename to admin_area_l3;

alter table "admin_area-l4_idn_mbd" rename to admin_area_l4;

alter table "admin_area-l5_idn_mbd" rename to admin_area_l5;

alter table "infra-airports_point-l3_idn_mtb" rename to infra_airports;

alter table "infra-roads_line-l3_idn_mtb"  rename to infra_roads ;

alter table "infra-seports_point-l3_idn_mtb" rename to infra_seaports;

alter table "trans-sea-lane_line-l3_idn_mtb" rename to trans_sea_lane;

-- correct all tables to have the correct number of columns by adding columns and
-- deleting other unecessary columns
alter table admin_area_l4 drop column shape_leng, drop column shape_area;

alter table admin_area_l5 add column sumber character varying(255), add column kecamatan character varying(255),add column desa_popul character varying(255);

alter table infra_airports drop column layer, drop column gm_type,drop column kml_folder;

alter table infra_seaports drop column layer, drop column gm_type,drop column kml_folder;
