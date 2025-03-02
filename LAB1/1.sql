ACCEPT v_number NUMBER PROMPT 'Enter a number: ';
declare
   v_number number;
   v_result number := 0;
begin
   v_number := &v_number;
   for i in 1..v_number loop
      v_result := v_result + i;
   end loop;
   dbms_output.put_line('the sum of the first '
                        || v_number
                        || ' natural numbers: '
                        || v_result);
end;
/