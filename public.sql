---------------------------------------------------------------------------------------
--Rename all tables to have names which are short and sensible
----------------------------------------------------------------------------------------

ALTER TABLE "admin_point-l5_idn_mtb_population" RENAME TO admin_point_l5;

ALTER TABLE "admin_area-l3_idn_mbd" RENAME TO admin_area_l3;

ALTER TABLE "admin_area-l4_idn_mbd" RENAME TO admin_area_l4;

ALTER TABLE "admin_area-l5_idn_mbd" RENAME TO admin_area_l5;

ALTER TABLE "infra-airports_point-l3_idn_mtb" RENAME TO infra_airports;

ALTER TABLE "infra-roads_line-l3_idn_mtb"  RENAME TO infra_roads ;

ALTER TABLE "infra-seports_point-l3_idn_mtb" RENAME TO infra_seaports;

ALTER TABLE "trans-sea-lane_line-l3_idn_mtb" RENAME TO trans_sea_lane;

----------------------------------------------------------------------------------------
--Altering sequences
-----------------------------------------------------------------------------------------
ALTER sequence "admin_area-l3_idn_mbd_gid_seq" RENAME TO admin_l3_areas_gid_seq;
                                    
ALTER sequence "admin_area-l4_idn_mbd_gid_seq" RENAME TO  admin_l4_areas_gid_seq;
                                
ALTER sequence "admin_area-l5_idn_mbd_gid_seq" RENAME TO admin_l5_areas_gid_seq;

ALTER sequence "admin_point-l5_idn_mtb_population_gid_seq" RENAME TO admin_l5_points_gid_seq;

ALTER sequence "infra-airports_point-l3_idn_mtb_gid_seq" RENAME TO infra_airports_points_gid_seq;
  
ALTER sequence "infra-roads_line-l3_idn_mtb_gid_seq" RENAME TO  infra_roads_lines_gid_seq;
      
ALTER sequence "infra-seports_point-l3_idn_mtb_gid_seq" RENAME TO infra_seports_points_gid_seq;

----------------------------------------------------------------------------------------------
--Altering index names and constraints names
----------------------------------------------------------------------------------------------
ALTER INDEX "admin_area-l3_idn_mbd_geom_gist"            RENAME TO admin_area_l3_geom_gist;

ALTER INDEX "admin_area-l3_idn_mbd_pkey"                 RENAME TO admin_area_l3_pkey;

ALTER INDEX "admin_area-l4_idn_mbd_geom_gist"            RENAME TO admin_area_l4_geom_gist;

ALTER INDEX "admin_area-l4_idn_mbd_pkey"                 RENAME TO admin_area_l4_pkey;

ALTER INDEX "admin_area-l5_idn_mbd_geom_gist"            RENAME TO admin_area_l5_geom_gist;

ALTER INDEX "admin_area-l5_idn_mbd_pkey"                 RENAME TO admin_area_l5_pkey;

ALTER INDEX "admin_point-l5_idn_mtb_population_geom_gist" RENAME TO admin_point_l5_geom_gist;

ALTER INDEX "admin_point-l5_idn_mtb_population_pkey"     RENAME TO admin_point_l5_pkey;

ALTER INDEX "infra-airports_point-l3_idn_mtb_geom_gist"  RENAME TO infra_airports_geom_gist;

ALTER INDEX "infra-airports_point-l3_idn_mtb_pkey"       RENAME TO infra_airports_pkey;

ALTER INDEX "infra-roads_line-l3_idn_mtb_geom_gist"      RENAME TO infra_roads_geom_gist;

ALTER INDEX "infra-roads_line-l3_idn_mtb_pkey"           RENAME TO infra_roads_pkey;

ALTER INDEX "infra-seports_point-l3_idn_mtb_geom_gist"   RENAME TO infra_seaports_geom_gist;

ALTER INDEX "infra-seports_point-l3_idn_mtb_pkey"        RENAME TO infra_seaports_pkey;

ALTER INDEX "trans-sea-lane_line-l3_idn_mtb_geom_gist"   RENAME TO trans_sea_lane_geom_gist;

ALTER INDEX "trans-sea-lane_line-l3_idn_mtb_pkey"        RENAME TO trans_sea_lane_pkey;

--------------------------------------------------------------------------------------------  
-- Correct all tables to have the correct number of columns by ADDing columns and
-- Deleting other unecessary columns
--------------------------------------------------------------------------------------------

ALTER TABLE admin_area_l4 DROP column shape_leng, DROP column shape_area;

ALTER TABLE admin_area_l5 ADD column sumber character varying(255), ADD column kecamatan character varying(255),ADD column desa_popul character varying(255);

ALTER TABLE infra_airports DROP column layer, DROP column gm_type,DROP column kml_folder;

ALTER TABLE infra_seaports DROP column layer, DROP column gm_type,DROP column kml_folder;
