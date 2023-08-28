WITH bcls
        AS (    SELECT   a.cfv_id,
                         a.mlt_id,
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
                         LEVEL top_level,
                         :prj_id prj_id
                  FROM  (select * from clv where clv.cfv_id = :cfv_id and clv.status <> 2) a
                 WHERE  a.status <> 2
            START WITH  cfv_id = :cfv_id
                    AND mlt_id = :mlt_id
                    AND clf_id = :clf_id
                    AND (a.cls_id = :cls_id or (:cls_id = -1 AND a.clv_clf_id is null))
            CONNECT BY      PRIOR cfv_id = cfv_id
                         AND PRIOR mlt_id = mlt_id
                         AND PRIOR clf_id = clv_clf_id
                         AND PRIOR cls_id = clv_cls_id)
SELECT   b.top_level AS "LEV",
         b.code AS "Код класса 1 уровня",
         b.name AS "Наименование класса 1 уровня",
         NULL AS "Код класса 2 уровня",
         NULL AS "Наименование класса 2 уровня",
         'Класс' AS "Тип строки",
         NULL AS "Шаб.крат.наим.\Норм.крат.наим.",
         NULL AS "Базовая ЕИ класса",
         NULL AS "Комментарий",  
         100 AS "DOP",
         b.code AS "Сортировка"
  FROM   bcls b
  where b.list = 0
  and b.status <> 2
UNION ALL
SELECT   b.top_level AS "LEV",
         NULL AS "Код класса 1 уровня",
         NULL AS "Наименование класса 1 уровня",
         b.code AS "Код класса 2 уровня",
         b.name AS "Наименование класса 2 уровня",
         'Класс' AS "Тип строки",
         NULL AS "Шаб.крат.наим.\Норм.крат.наим.",
         ums.code AS "Базовая ЕИ класса",
         NULL AS "Комментарий",  
         100 AS "DOP",
         b.code AS "Сортировка"
  FROM   bcls b, cum, ums
  where b.list = 1
    and b.mlt_id = cum.mlt_id (+)
    and b.clf_id = cum.clf_id (+)
    and b.cls_id = cum.cls_id (+)
    and b.prj_id = cum.prj_id (+)
    and cum.cst_id (+) = :cst_id
    and cum.ums_id = ums.ums_id (+)
UNION ALL
SELECT   15 AS "LEV",
         NULL AS "Код класса 1 уровня",
         NULL AS "Наименование класса 1 уровня",
         NULL AS "Код класса 2 уровня",
         NULL AS "Наименование класса 2 уровня",
         'Шаблон' AS "Тип строки",
         REGEXP_REPLACE (gen_shbl_cls_pp_ink (:cfv_id,
                              b.MLT_ID,
                              b.CLF_ID,
                              b.CLS_ID,
                              q.sname,
                              1), '&|#', '') AS "Шаб.крат.наим.\Норм.крат.наим.",
         NULL AS "Базовая ЕИ класса",
         NULL AS "Комментарий",
         150 AS "DOP",
         b.code AS "Сортировка"
FROM  bcls b, nmpp q
WHERE b.mlt_id = q.mlt_id
  AND b.clf_id = q.clf_id
  AND b.cls_id = q.cls_id
  AND b.prj_id = q.prj_id
  AND b.list = 1
  and exists (select 1 from ocl, obj
                where ocl.mlt_id = b.mlt_id
                  and ocl.clf_id = b.clf_id
                  and ocl.cls_id = b.cls_id
                  and ocl.mlt_id = obj.mlt_id
                  and ocl.obj_id = obj.obj_id
                  and obj.prj_id = 73
                  and obj.status = 1)
ORDER BY   11, 10, 7