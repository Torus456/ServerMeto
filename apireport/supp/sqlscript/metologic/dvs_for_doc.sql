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
       level clv_lev
from clv, cfv, prj
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
  and prj.prj_id = :prj_id
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id),
nclv as
(select bcls.mlt_id,
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
       gen_shbl_cls_pp2(  bcls.cfv_id,
	                      bcls.mlt_id,
	                      bcls.clf_id,
	                      bcls.cls_id,
	                      nmpp.sname,
	                      1) sname,
       gen_shbl_cls_pp2(  bcls.cfv_id,
	                      bcls.mlt_id,
	                      bcls.clf_id,
	                      bcls.cls_id,
	                      nmpp.fname,
	                      1) fname,
                          nmpp.fname nfname
from bcls, nmpp
where bcls.mlt_id = nmpp.mlt_id 
  and bcls.clf_id = nmpp.clf_id
  and bcls.cls_id = nmpp.cls_id
  and bcls.prj_id = nmpp.prj_id)
select distinct
       b.mlt_id,
       b.clf_id,
       b.cls_id,
       b.cfv_id,
       b.code cls_code,
       b.name cls_name,
       b.prj_id,
       b.project_name,
       sgn.sgn_id,
       sdv.dvs_id,
       sdv.code,
       sdv.name || case when sd.dvs_id is not null then '(Не обязательный)' else null end name,
       sdv.ord,
       nvl( q.chislovojtekstovyj,
       		case when sgn.valtype = 0 then 'Текстовый' 
			when up_zhaikmuhay.get_type_dvs_pp(sdv.mlt_id, sdv.clf_id, sdv.cls_id, sdv.sgn_id, sdv.dvs_id, :prj_id) = 1 then 'Текстовый' 
			else 'Числовой' end)  valtype     
from nclv b, sdv, sgn, cs_art_load.uni_dvs_done_all q, cs_art_load.sinara_not_needs_od sd
where b.mlt_id = sdv.mlt_id 
  and b.clf_id = sdv.clf_id 
  and b.cls_id = sdv.cls_id
  and b.cfv_id = sdv.cfv_id
  and sdv.mlt_id = q.mlt_id (+)
  and sdv.clf_id = q.clf_id (+)
  and sdv.cls_id = q.cls_id (+)
  and sdv.sgn_id = q.sgn_id (+)
  and sdv.dvs_id = q.dvs_id (+)
  and sdv.mlt_id = sd.mlt_id (+)
  and sdv.clf_id = sd.clf_id (+)
  and sdv.cls_id = sd.cls_id (+)
  and sdv.dvs_id = sd.dvs_id (+)
  and sdv.mlt_id = sgn.mlt_id
  and sdv.sgn_id = sgn.sgn_id
  and regexp_like(b.nfname,'{([^[{]*)\[&?'||sdv.dvs_id|| '\]')
order by b.code, sdv.ord