with Ada.Text_IO; use Ada.Text_IO;

procedure main is
   NumElements : constant := 1000;
   type my_array is array (1 .. NumElements) of Integer;

   a : my_array;
   size, new_size: Integer;

   procedure create_array is
   begin
      for i in a'Range loop
         a (i) := i;
      end loop;
   end create_array;

   task type my_task is
       entry start (left, right : in Integer);
       entry synch (finish: in Boolean);
   end my_task;

   task body my_task is
      left, Right : Integer;
      finish: Boolean;
   begin
      loop
         accept start (left, right : in Integer) do
           my_task.left  := left;
           my_task.right := right;
         end start;

         a(my_task.left) :=  a(my_task.left) + a(my_task.right);

         accept synch(finish: in Boolean) do
            my_task.finish := finish;
         end synch;
         exit when my_task.finish;

      end loop;
   end my_task;

   tasks : array (1 .. NumElements/2) of my_task;
begin
   create_array;

   size := NumElements;

   while size > 1 loop
      for i in 1..size/2 loop
         tasks(i).start(i, size - i + 1);
      end loop;

      new_size := size/2 + (size mod 2);

      for i in 1..size/2 loop
         tasks(i).synch(i>new_size/2);
      end loop;

      size := new_size;
   end loop;

   Put_Line ("Multi-thread sum: " & a(1)'Img);

end main;
