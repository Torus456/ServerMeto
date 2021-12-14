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
       level clv_lev,
       connect_by_isleaf list
from clv, cfv, prj
where clv.cfv_id = cfv.cfv_id
  and prj.prj_id = cfv.prj_id
  and clv.status <> 2
start with clv.mlt_id = :mlt_id
  and clv.clf_id = :clf_id
  and clv.cls_id = :cls_id
  and clv.cfv_id = :cfv_id
connect by prior clv.mlt_id = clv.mlt_id
  and prior clv.cfv_id = clv.cfv_id 
  and prior clv.clf_id = clv.clv_clf_id
  and prior clv.cls_id = clV.clv_cls_id),
bsdv as (
    select sdv.mlt_id,
           sdv.clf_id,
           sdv.cls_id,
           sdv.dvs_id,
           sdv.sgn_id,
           sdv.cfv_id,
           sdv.code,
           sdv.name,
           bcls.prj_id,
           bcls.code cls_code,
           bcls.name cls_name,
           sdv.ord,
           sgn.valtype,
           sgn.name sgn_name, 
           REGEXP_COUNT(p.fname||p.sname, '\[.?'||sdv.dvs_id||'\]\[#') only_dop
    from sdv, bcls, sgn, nmpp p  
    where sdv.mlt_id = bcls.mlt_id
      and sdv.clf_id = bcls.clf_id
      and sdv.cls_id = bcls.cls_id
      and sdv.cfv_id = bcls.cfv_id
      and sdv.mlt_id = sgn.mlt_id
      and sdv.sgn_id = sgn.sgn_id
      and bcls.list = 1
      and sdv.mlt_id = p.mlt_id
      and sdv.clf_id = p.clf_id
      and sdv.cls_id = p.cls_id
      and p.prj_id = bcls.prj_id
      and REGEXP_LIKE (p.fname, '\[.?'||sdv.dvs_id||'\]')),
zdvs as 
(select *
     from (select   distinct
           dvs.mlt_id,
           dvs.clf_id,
           dvs.cls_id,
           dvs.sgn_id,
           dvs.dvs_id,
           dvs.code,
           dvs.name,
           nvl(dvs.multival_sep, ',') multival_sep,           
           connect_by_root (dvs.clf_id) root_clf,
           connect_by_root (dvs.cls_id) root_cls,
           connect_by_root (dvs.sgn_id) root_sgn,
           connect_by_root (dvs.dvs_id) root_dvs,
           level lev
            from dvs
            where dvs.mlt_id = 1
              and exists (select 1
                          from nmpp p
                          where dvs.mlt_id = p.mlt_id
                            and dvs.clf_id = p.clf_id
                            and dvs.cls_id = p.cls_id
                            and p.prj_id = :prj_id
                            and REGEXP_LIKE (p.fname, '\[.?'||dvs.dvs_id||'\]'))
            start with dvs.mlt_id = 1
              and (dvs.mlt_id, dvs.clf_id, dvs.cls_id, dvs.sgn_id, dvs.dvs_id) in
                       (select bsdv.mlt_id, bsdv.clf_id, bsdv.cls_id, bsdv.sgn_id, bsdv.dvs_id
                         from bsdv)
            connect by prior dvs.mlt_id = dvs.mlt_id
              and prior dvs.clf_id = dvs.clf_id
              and prior dvs.sgn_id = dvs.sgn_id
              and prior dvs.cls_id = dvs.dvs_cls_id
              and prior dvs.dvs_id = dvs.dvs_dvs_id) a
              where gen_shbl_dvs_sgn(a.mlt_id,a.clf_id,a.cls_id,:prj_id,1) 
                    = gen_shbl_dvs_sgn(a.mlt_id,a.root_clf,a.root_cls,:prj_id,1)),
xdvs as 
(select  bsdv.mlt_id,
         nvl (zdvs.clf_id, bsdv.clf_id) as clf_id,
         nvl (zdvs.cls_id, bsdv.cls_id) as cls_id,
         nvl (zdvs.sgn_id, bsdv.sgn_id) as sgn_id,
         nvl (zdvs.dvs_id, bsdv.dvs_id) as dvs_id,
         bsdv.clf_id as clf_id_pp,
         bsdv.cls_id as cls_id_pp,
         bsdv.sgn_id as sgn_id_pp,
         bsdv.dvs_id as dvs_id_pp,
         bsdv.code,
         bsdv.name,
         bsdv.prj_id,
         bsdv.ord,
         zdvs.multival_sep
from bsdv, zdvs 
where bsdv.mlt_id = zdvs.mlt_id (+)
  and bsdv.clf_id = zdvs.root_clf (+)
  and bsdv.cls_id = zdvs.root_cls (+)
  and bsdv.sgn_id = zdvs.root_sgn (+)
  and bsdv.dvs_id = zdvs.root_dvs (+)),
zvsn as 
(select distinct  bsdv.mlt_id,
        bsdv.clf_id,
        bsdv.cls_id,
        bsdv.cfv_id,
        bsdv.cls_code cls_code,
        bsdv.cls_name cls_name,
        :prj_id prj_id,
        bsdv.sgn_id,
        bsdv.dvs_id,
        bsdv.code,
        bsdv.name,
        bsdv.ord,
        bsdv.valtype, 
        case when vsn.vsn_id = 0 then vsn.symsgn
             else case when bsdv.valtype = 0 then sp_acceptor.return_values (bsdv.mlt_id, bsdv.clf_id, bsdv.cls_id, bsdv.prj_id, bsdv.dvs_id, bsdv.sgn_id, vsn.vsn_id,0)
                       else replace(regexp_replace(to_char(vsn.valnum), '^\.', '0.'), '.', ',') 
                  end
        end value,
        sp_acceptor.return_values (bsdv.mlt_id, bsdv.clf_id, bsdv.cls_id, bsdv.prj_id, bsdv.dvs_id, bsdv.sgn_id, vsn.vsn_id,1) symsgn,
         case when vsn.vsn_id = 0 then vsn.symsgn
             else case when bsdv.valtype = 0 then vsn.valchar
                       else replace(regexp_replace(to_char(vsn.valnum), '^\.', '0.'), '.', ',') 
                  end
        end valchar,
        :inclf_id inclf_id,
        obj.obj_id,
        xdvs.multival_sep,
        vsn.vsn_id,
        bsdv.only_dop
from bsdv, 
     xdvs, 
     obj,
     ocl, 
     vso, 
     vsn,
     oclp
where bsdv.mlt_id = xdvs.mlt_id
  and bsdv.clf_id = xdvs.clf_id_pp
  and bsdv.cls_id = xdvs.cls_id_pp
  and bsdv.sgn_id = xdvs.sgn_id_pp
  and bsdv.dvs_id = xdvs.dvs_id_pp
  and xdvs.mlt_id = ocl.mlt_id
  and xdvs.clf_id = ocl.clf_id
  and xdvs.cls_id = ocl.cls_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and xdvs.mlt_id = vso.mlt_id
  and xdvs.clf_id = vso.clf_id
  and xdvs.cls_id = vso.cls_id
  and xdvs.dvs_id = vso.dvs_id
  and xdvs.sgn_id = vso.sgn_id
  and ocl.clf_id = :inclf_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.prj_id = bsdv.prj_id
  and oclp.fname||oclp.sname not like '%?%'
  and obj.prj_id = bsdv.prj_id
  and obj.status = 1
  and exists (select 1 
             from vobj
             where vobj.aobj_id = :aobj_id
               and vobj.mlt_id = obj.mlt_id
               and vobj.obj_id = obj.obj_id)
  and vso.mlt_id = vsn.mlt_id
  and vso.sgn_id = vsn.sgn_id
  and vso.vsn_id = vsn.vsn_id
union all
select distinct  bsdv.mlt_id,
        bsdv.clf_id,
        bsdv.cls_id,
        bsdv.cfv_id,
        bsdv.cls_code cls_code,
        bsdv.cls_name cls_name,
        :prj_id prj_id,
        bsdv.sgn_id,
        bsdv.dvs_id,
        bsdv.code,
        bsdv.name,
        bsdv.ord,
        bsdv.valtype, 
        case when vsn.vsn_id = 0 then vsn.symsgn
             else case when bsdv.valtype = 0 then sp_acceptor.return_values (bsdv.mlt_id, bsdv.clf_id, bsdv.cls_id, bsdv.prj_id, bsdv.dvs_id, bsdv.sgn_id, vsn.vsn_id,0)
                       else replace(regexp_replace(to_char(vsn.valnum), '^\.', '0.'), '.', ',') 
                  end
        end value,
        sp_acceptor.return_values (bsdv.mlt_id, bsdv.clf_id, bsdv.cls_id, bsdv.prj_id, bsdv.dvs_id, bsdv.sgn_id, vsn.vsn_id,1) symsgn,
        case when vsn.vsn_id = 0 then vsn.symsgn
             else case when bsdv.valtype = 0 then vsn.valchar
                       else replace(regexp_replace(to_char(vsn.valnum), '^\.', '0.'), '.', ',') 
                  end
        end valchar,
        :inclf_id inclf_id,
        obj.obj_id,
        xdvs.multival_sep,
        vsn.vsn_id,
        bsdv.only_dop
from bsdv, 
     xdvs, 
     obj,
     ocl, 
     vso, 
     vsn,
     oclp
where bsdv.mlt_id = xdvs.mlt_id
  and bsdv.clf_id = xdvs.clf_id_pp
  and bsdv.cls_id = xdvs.cls_id_pp
  and bsdv.sgn_id = xdvs.sgn_id_pp
  and bsdv.dvs_id = xdvs.dvs_id_pp
  and xdvs.mlt_id = ocl.mlt_id
  and xdvs.clf_id = ocl.clf_id
  and xdvs.cls_id = ocl.cls_id
  and ocl.mlt_id = vso.mlt_id
  and ocl.clf_id = vso.clf_id
  and ocl.cls_id = vso.cls_id
  and ocl.obj_id = vso.obj_id
  and xdvs.mlt_id = vso.mlt_id
  and xdvs.clf_id = vso.clf_id
  and xdvs.cls_id = vso.cls_id
  and xdvs.dvs_id = vso.dvs_id
  and xdvs.sgn_id = vso.sgn_id
  and ocl.clf_id = 6
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.prj_id = bsdv.prj_id
  and ocl.mlt_id = oclp.mlt_id
  and ocl.clf_id = oclp.clf_id
  and ocl.cls_id = oclp.cls_id
  and ocl.obj_id = oclp.obj_id
  and oclp.prj_id = bsdv.prj_id
  and oclp.fname||oclp.sname not like '%?%'
  and obj.status = 1
  and not exists (select 1
                  from ocl oclin
                  where ocl.mlt_id = oclin.mlt_id
                    and ocl.obj_id = oclin.obj_id
                    and oclin.clf_id = :inclf_id)
  and exists (select 1 
             from vobj
             where vobj.aobj_id = :aobj_id
               and vobj.mlt_id = obj.mlt_id
               and vobj.obj_id = obj.obj_id)
  and vso.mlt_id = vsn.mlt_id
  and vso.sgn_id = vsn.sgn_id
  and vso.vsn_id = vsn.vsn_id)
select distinct q.mlt_id,
        q.clf_id,
        q.cls_id,
        q.cfv_id,
        q.cls_code,
        q.cls_name,
        q.prj_id,
        q.sgn_id,
        q.dvs_id,
        q.code,
        q.name,
        q.ord,
        q.valtype, 
        case when q.sgn_id = 8222 then NVL(q.symsgn, q.value)
             when (q.only_dop = 2 AND LENGTH(q.value) = LENGTH(q.symsgn)) then q.symsgn
             when replace(q.value, '.', ',') = replace(q.symsgn, '.', ',') then q.symsgn
        else REPLACE(q.value, '<Отсутствует>', '   ')
        end value,
        case 
             when q.cnt > 0 then REPLACE(q.symsgn, '<Отсутствует>', '   ') 
             when q.sgn_id = 8222 then '   '
             when (q.only_dop = 2 AND LENGTH(q.value) = LENGTH(q.symsgn)) then '   '
             when replace(q.value, '.', ',') = replace(q.symsgn, '.', ',') then '   ' 
             when q.value = q.symsgn then '   '
             else REPLACE(q.symsgn, '<Отсутствует>', '   ') 
        end symsgn,
        q.inclf_id,
        q.vsn_id,
        q.only_dop
from
(select q.mlt_id,
        q.clf_id,
        q.cls_id,
        q.cfv_id,
        q.cls_code,
        q.cls_name,
        q.prj_id,
        q.sgn_id,
        q.dvs_id,
        q.code,
        q.name,
        q.ord,
        q.valtype, 
        q.value,
        q.symsgn,
        q.vsn_id,
        q.inclf_id,
        q.obj_id,
        q.only_dop,
        count(case when  symsgn = '<Отсутствует>' then 1 else null end) over (partition by q.mlt_id,
        q.clf_id,
        q.cls_id,
        q.cfv_id,
        q.cls_code,
        q.cls_name,
        q.prj_id,
        q.sgn_id,
        q.dvs_id) cnt 
from   
(select  zvsn.mlt_id,
        zvsn.clf_id,
        zvsn.cls_id,
        zvsn.cfv_id,
        zvsn.cls_code,
        zvsn.cls_name,
        zvsn.prj_id,
        zvsn.sgn_id,
        zvsn.dvs_id,
        zvsn.code,
        zvsn.name,
        zvsn.ord,
        zvsn.valtype, 
        LISTAGG(zvsn.valchar, zvsn.multival_sep) within group (ORDER BY zvsn.value) value,
        LISTAGG( case when zvsn.valchar = zvsn.value then zvsn.symsgn
                      else NVL(zvsn.value,zvsn.symsgn)
                 end, zvsn.multival_sep
        ) within group (ORDER BY zvsn.value) symsgn,
        LISTAGG(zvsn.vsn_id, zvsn.multival_sep) within group (ORDER BY zvsn.vsn_id) vsn_id,
        zvsn.inclf_id,
        zvsn.obj_id,
        zvsn.only_dop         
from zvsn
group by  zvsn.mlt_id,
        zvsn.clf_id,
        zvsn.cls_id,
        zvsn.cfv_id,
        zvsn.cls_code,
        zvsn.cls_name,
        zvsn.prj_id,
        zvsn.sgn_id,
        zvsn.dvs_id,
        zvsn.code,
        zvsn.name,
        zvsn.ord,
        zvsn.valtype,
        zvsn.inclf_id,
        zvsn.obj_id,
        zvsn.multival_sep,
        zvsn.only_dop) q) q 
order by cls_code, ord, case when vsn_id like '0%' then null else '1' end, 14