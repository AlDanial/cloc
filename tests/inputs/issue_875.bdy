/*
 * bubble sort
 */
DECLARE
  TYPE number_array IS VARRAY(100) OF NUMBER;
  arr number_array := number_array(64, 34, 25, 12, 22, 11, 90);
  n NUMBER := arr.COUNT;
  i NUMBER := 0;
  j NUMBER := 0;
  temp NUMBER;
BEGIN
  FOR i IN 1 .. (n - 1) LOOP -- outer
    FOR j IN 1 .. (n - i - 1) LOOP -- inner
      IF arr(j) > arr(j + 1) THEN
        temp := arr(j);
        arr(j) := arr(j + 1);
        arr(j + 1) := temp;
      END IF;
    END LOOP;
  END LOOP;
  -- print
  FOR i IN 1 .. n LOOP
    DBMS_OUTPUT.PUT_LINE(arr(i));
  END LOOP;
END;
/
