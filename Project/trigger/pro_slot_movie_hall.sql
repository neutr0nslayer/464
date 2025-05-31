create or replace procedure update_movie_for_slot (
   p_slot_id      slottable.slotid%type,
   p_new_movie_id slottable.movietable_movieid%type
) as
begin
   update slottable
      set
      movietable_movieid = p_new_movie_id
    where slotid = p_slot_id;

   if sql%rowcount = 0 then
      raise_application_error(
         -20020,
         'No slot found with slotid=' || p_slot_id
      );
   end if;

   commit;
end update_movie_for_slot;
/

create or replace procedure update_hall_for_slot (
   p_slot_id     slottable.slotid%type,
   p_new_hall_id slottable.halltable_hallid%type
) as
begin
   update slottable
      set
      halltable_hallid = p_new_hall_id
    where slotid = p_slot_id;

   if sql%rowcount = 0 then
      raise_application_error(
         -20021,
         'No slot found with slotid=' || p_slot_id
      );
   end if;

   commit;
end update_hall_for_slot;
/