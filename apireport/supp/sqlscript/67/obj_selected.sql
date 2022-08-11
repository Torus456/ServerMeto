WITH bcls
        AS (    SELECT   a.cfv_id,a.mlt_id,
                         a.clf_id,
                         a.cls_id,
                         a.parent,
                         a.status,
                         a.name,
                         a.code,
                         a.code_key,
                         a.clv_clf_id,
                         a.clv_cls_id,
                         CONNECT_BY_ISLEAF list,
                         LEVEL top_level
                  FROM   (select * from clv where clv.cfv_id = :cfv_id and clv.mlt_id = :mlt_id and status <> 2) a
            START WITH       cfv_id = :cfv_id
                         AND mlt_id = :mlt_id
                         AND clf_id = :clf_id
                         AND (cls_id = :cls_id OR (:cls_id = -1 AND clv_cls_id IS NULL))
            CONNECT BY      PRIOR cfv_id = cfv_id
                         AND PRIOR mlt_id = mlt_id
                         AND PRIOR clf_id = clv_clf_id
                         AND PRIOR cls_id = clv_cls_id),
    zcls
        AS (SELECT   *
              FROM   (    SELECT   DISTINCT
                                   cls.mlt_id,
                                   cls.clf_id,
                                   cls.cls_id,
                                   cls.code,
                                   cls.name,
                                   CONNECT_BY_ROOT (cls.cls_id) root_cls,
                                   CONNECT_BY_ROOT (cls.clf_id) root_clf,
                                   LEVEL lev,
                                   :prj_id prj_id,
                                   :cst_id cst_id,
                                   :inclf_id inclf_id,
                                   :aobj_id aobj_id
                            FROM   cls
                           WHERE   cls.mlt_id = 1
                      START WITH   cls.mlt_id = 1 AND cls.clf_id IN (6, 3530)
                                   AND EXISTS
                                          (SELECT   1
                                             FROM   bcls
                                            WHERE   bcls.list = 1
                                                    AND bcls.mlt_id =
                                                           cls.mlt_id
                                                    AND bcls.clf_id =
                                                           cls.clf_id
                                                    AND bcls.cls_id =
                                                           cls.cls_id)
                      CONNECT BY       PRIOR mlt_id = mlt_id
                                   AND PRIOR clf_id = clf_id
                                   AND PRIOR cls_id = cls_cls_id) a
             WHERE   gen_shbl_dvs_sgn (a.mlt_id,
                                       a.clf_id,
                                       a.cls_id,
                                       :prj_id,
                                       1) = gen_shbl_dvs_sgn (a.mlt_id,
                                                              a.root_clf,
                                                              a.root_cls,
                                                              :prj_id,
                                                              1)),                                                        
    xcls
        AS (SELECT   b.mlt_id,
                     NVL (z.clf_id, b.clf_id) AS clf_id,
                     NVL (z.cls_id, b.cls_id) AS cls_id,
                     b.clf_id AS clf_id_pp,
                     b.cls_id AS cls_id_pp,
                     b.code,
                     b.name,
                     b.parent
              FROM   bcls b, zcls z
             WHERE       b.mlt_id = z.mlt_id(+)
                     AND b.clf_id = z.root_clf(+)
                     AND b.cls_id = z.root_cls(+))
select rownum "№ п/п",
       q.*
from 
(select obj.name "Наименование",
       obj.code "Код НСИ",
       ums.code "ЕИ",
       grp.name "Группа",
       art.artikul "Артикул",
       obj.fname "Описание"           
from obj, 
     ocl, 
     xcls, 
     ocl ogrp, 
     cls grp, 
     oum, 
     ums,
     cs_art_load.ink_artikul art
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1
  and obj.prj_id = :prj_id
  and ocl.mlt_id = 1
  and ocl.clf_id = :inclf_id 
  and obj.mlt_id = ogrp.mlt_id (+)
  and obj.obj_id = ogrp.obj_id (+)
  and ogrp.clf_id (+) = 3510
  and ogrp.mlt_id = grp.mlt_id (+)
  and ogrp.clf_id = grp.clf_id (+)
  and ogrp.cls_id = grp.cls_id (+)
  and obj.mlt_id = oum.mlt_id (+)
  and obj.obj_id = oum.obj_id (+)
  and oum.prj_id (+) = 67
  and oum.cst_id (+) = 487
  and oum.ums_id = ums.ums_id (+)
  and obj.obj_id = art.obj_id (+)
union all 
select obj.name "Наименование",
       obj.code "Код НСИ",
       ums.code "ЕИ",
       grp.name "Группа",
       art.artikul "Артикул",
       obj.fname "Описание"           
from obj, 
     ocl, 
     xcls, 
     ocl ogrp, 
     cls grp, 
     oum, 
     ums,
     cs_art_load.ink_artikul art
where xcls.mlt_id = ocl.mlt_id
  and xcls.clf_id = ocl.clf_id
  and xcls.cls_id = ocl.cls_id
  and ocl.mlt_id = obj.mlt_id
  and ocl.obj_id = obj.obj_id
  and obj.status = 1
  and obj.prj_id = :prj_id
  and ocl.mlt_id = 1
  and ocl.clf_id = 6
  and not exists (select 1 
            from ocl q
            where ocl.mlt_id = q.mlt_id
              and ocl.obj_id = q.obj_id
              and q.clf_id = :inclf_id)
  and obj.mlt_id = ogrp.mlt_id (+)
  and obj.obj_id = ogrp.obj_id (+)
  and ogrp.clf_id (+) = 3510
  and ogrp.mlt_id = grp.mlt_id (+)
  and ogrp.clf_id = grp.clf_id (+)
  and ogrp.cls_id = grp.cls_id (+)
  and obj.mlt_id = oum.mlt_id (+)
  and obj.obj_id = oum.obj_id (+)
  and oum.prj_id (+) = 67
  and oum.cst_id (+) = 487
  and oum.ums_id = ums.ums_id (+)
  and obj.obj_id = art.obj_id (+)
  order by 1
  ) q
order by 1
