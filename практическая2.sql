-- 1. выбрать номера компьютерных лабалаторий, с вакантной должностью заведующего лабалаторией
SELECT * FROM public.labs
WHERE head_of_lab IS NULL
AND public.labs.line_of_activity ILIKE '%компьютер%';

-- 2. выбрать номера всех лабалаторий, входящих в состав выпускающих кафедр
SELECT public.labs.lab_num FROM public.labs
INNER JOIN public.departments ON public.labs.department_num = public.departments.department_num
WHERE degree_granting_department IS TRUE;

-- 3. создать таблицу, содержащую данные 1 запроса с указанием кафедр, к которым относятся лабалатории, и данных из таблицы "лабалатории"
SELECT 
    l.lab_num,
    l.lab_name,
    l.line_of_activity,
    l.head_of_lab,
    l.jobs_ammount,
    l.equipment_availability,
    d.department_num,
    d.department_name,
    d.faculty_code,
    d.degree_granting_department
INTO public.graduating_labs_info
FROM public.labs l
INNER JOIN public.departments d ON l.department_num = d.department_num
WHERE l.head_of_lab IS NULL 
AND l.line_of_activity ILIKE '%компьютер%';

-- 4. Добавить в созданную таблицу все лабалатории кафедр, название которых начинаются на согласные буквы.
INSERT INTO public.graduating_labs_info (
    lab_num, lab_name, line_of_activity, head_of_lab, 
    jobs_ammount, equipment_availability, department_num, 
    department_name, faculty_code, degree_granting_department
)
SELECT 
    l.lab_num,
    l.lab_name,
    l.line_of_activity,
    l.head_of_lab,
    l.jobs_ammount,
    l.equipment_availability,
    d.department_num,
    d.department_name,
    d.faculty_code,
    d.degree_granting_department
FROM public.labs l
INNER JOIN public.departments d ON l.department_num = d.department_num
WHERE d.department_name ~* '^[бвгджзйклмнпрстфхцчшщ]';

-- 5. Увеличить количество рабочих мест в 2 раза всем лабалаториям, имеющим проектное оборудование
UPDATE public.labs
SET jobs_ammount = jobs_ammount * 2
WHERE equipment_availability IS TRUE;

-- 6. Из созданной таблицы удалить все записи для лабалаторий, находящихся на 2 этаже
DELETE FROM public.graduating_labs_info
WHERE lab_num::text LIKE '2%';

-- 7. Посчитать количество лабалаторий и среднее количество оборудованных мест в лабалаториях на каждой кафедре.
SELECT 
    d.department_name AS "Название кафедры",
    COUNT(l.lab_num) AS "Количество лабораторий",
    ROUND(AVG(l.jobs_ammount), 1) AS "Среднее количество мест"
FROM public.departments d
LEFT JOIN public.labs l ON d.department_num = l.department_num
GROUP BY d.department_num, d.department_name
ORDER BY d.department_name;
