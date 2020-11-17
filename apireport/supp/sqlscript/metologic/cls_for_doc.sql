with bcls as 
(select clv.mlt_id,
       clv.clf_id,
       clv.cls_id,
       clv.clv_clf_id,
       clv.clv_cls_id,
       clv.name,
       clv.code,
       clv.cfv_id,
       prj.prj_id,
       prj.name project_name,
       connect_by_isleaf isleaf,
       level clv_lev
from clv, cfv, prj
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id)
select bcls.mlt_id,
       bcls.clf_id,
       bcls.cls_id,
       bcls.clv_clf_id,
       bcls.clv_cls_id,
       bcls.name,
       bcls.code,
       bcls.cfv_id,
       bcls.prj_id,
       bcls.project_name,
       bcls.clv_lev,
       case when isleaf = 1 then 
	       	gen_shbl_cls_pp2(  bcls.cfv_id,
			                   bcls.mlt_id,
			                   bcls.clf_id,
			                   bcls.cls_id,
			                   nmpp.sname,
			                   1) 
	   else null end sname,
	   case when isleaf = 1 then
		   gen_shbl_cls_pp2(  bcls.cfv_id,
		                      bcls.mlt_id,
		                      bcls.clf_id,
		                      bcls.cls_id,
		                      nmpp.fname,
		                      1) 
	   else null end fname,
	   case when isleaf = 1 then 
		   (select max(ums.code)
		    from cum, ums
		    where cum.mlt_id = bcls.mlt_id
		      and cum.clf_id = bcls.clf_id
		      and cum.cls_id = bcls.cls_id
		      and cum.cst_id = 466
		      and cum.prj_id = 62
		      and cum.ums_id = ums.ums_id) 
		   else null end ums_code,
	   case when isleaf = 1 then
	   (select max(ums.name)
	    from cum, ums
	    where cum.mlt_id = bcls.mlt_id
	      and cum.clf_id = bcls.clf_id
	      and cum.cls_id = bcls.cls_id
	      and cum.cst_id = 466
	      and cum.prj_id = 62
	      and cum.ums_id = ums.ums_id)
	    else null end ums_name
from bcls, nmpp
where bcls.mlt_id = nmpp.mlt_id (+) 
  and bcls.clf_id = nmpp.clf_id (+)
  and bcls.cls_id = nmpp.cls_id (+)
  and bcls.prj_id = nmpp.prj_id (+)