################################
## 		 	 QUERIES		  ##
################################

# get information of all orders for a single customer

select O.Customer_id, OD.Product_ID, OD.Order_quantity, P.Selling_Price, (OD.Order_quantity * P.Selling_Price) as Order_Amount
from Orders O, Order_Details OD, Product P
where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = 1
group by P.Product_id, OD.Order_Quantity;


################################
## 		  PROCEDURES		  ##
################################

# calculate the total amount of all orders of a single customer

drop procedure if exists calcAmount;
delimiter //
create procedure calcAmount(x int)

Begin
Declare Total decimal(20, 2);
	select SUM(q1.Item_Amount) as Total_Amount into Total from (
		select OD.Order_quantity * P.Selling_Price as Item_Amount
		from Orders O, Order_Details OD, Product P
		where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = x
		group by P.Product_id, OD.Order_Quantity
	) as q1;

  Select Total as amountSpent;

end//
delimiter ;

call calcAmount(1);


################################
## 		   FUNCTIONS		  ##
################################

# calculate the points earned by a single customer

SET GLOBAL log_bin_trust_function_creators=1;

drop function if exists calcPoints;
delimiter //
create function calcPoints(x int) returns int
Begin
	Declare pt int;
  Declare total decimal(20, 2);

	select SUM(q1.Item_Amount) as Total_Amount into total from (
		select OD.Order_quantity * P.Selling_Price as Item_Amount
		from Orders O, Order_Details OD, Product P
		where O.Order_Number = OD.Order_number and OD.Product_ID = P.Product_ID and O.Customer_id = x
		group by P.Product_id, OD.Order_Quantity
	) as q1;

  set pt = total;

Return(pt);
end//
delimiter ;

select calcPoints(1) as pointsEarned;

################################
##		 	TRIGGERS		  ##
################################

# Clear the points of a customer before the next order

drop trigger if exists clearPointsBeforeOrder;
delimiter //

create trigger clearPointsBeforeOrder
	before insert
	on Orders for each row
Begin
	If exists(select customer_ID from customers where customer_ID = new.Customer_ID)
		then update customers set points = 0 where customers.customer_id = new.customer_id;
    end if;

end//

delimiter ;


# TEST

insert into Orders values (9,1,date('2020-5-30'),date('2020-06-02'));

select * from customers where customer_ID = 1;
