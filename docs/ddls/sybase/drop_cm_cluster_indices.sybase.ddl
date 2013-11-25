--
-- table: cm_cluster_members
--
ALTER TABLE cm_cluster_members DROP CONSTRAINT fk_cm_cluster_members04;
ALTER TABLE cm_cluster_members DROP CONSTRAINT fk_cm_cluster_members03;
ALTER TABLE cm_cluster_members DROP CONSTRAINT fk_cm_cluster_members02;
ALTER TABLE cm_cluster_members DROP CONSTRAINT fk_cm_cluster_members01;

--
-- table: cm_clusters
--
ALTER TABLE cm_clusters DROP CONSTRAINT fk_cm_clusters02;
ALTER TABLE cm_clusters DROP CONSTRAINT fk_cm_clusters01;



---------------------------------------------------------------------------------------------
--
-- Once all foreign key constraints are dropped, we can drop the indices
--
---------------------------------------------------------------------------------------------

--
-- table: cm_cluster_members
--
DROP INDEX cm_cluster_members.idx_cm_cluster_members04;
DROP INDEX cm_cluster_members.idx_cm_cluster_members03;
DROP INDEX cm_cluster_members.idx_cm_cluster_members02;
DROP INDEX cm_cluster_members.pk_cm_cluster_members;

--
-- table: cm_clusters
--
DROP INDEX cm_clusters.pk_cm_clusters;

--
-- table: cm_proteins
--
DROP INDEX cm_proteins.idx_cm_proteins06;
DROP INDEX cm_proteins.idx_cm_proteins05;
DROP INDEX cm_proteins.idx_cm_proteins04;
DROP INDEX cm_proteins.idx_cm_proteins03;
DROP INDEX cm_proteins.idx_cm_proteins02;
DROP INDEX cm_proteins.pk_cm_proteins;


--
-- Drop the clustered indexes
--
DROP INDEX cm_cluster_members.idx_cm_cluster_members01;
DROP INDEX cm_clusters.idx_cm_clusters01;
