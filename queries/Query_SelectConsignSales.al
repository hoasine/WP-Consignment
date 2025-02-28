query 50082 "SelectConsignSales"
{
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(Source_TransactionHeader; "LSC Transaction Header")
        {
            DataItemTableFilter = "Entry Status" = filter('' | Voided);
            filter(Filter_Date; "Date") { }
            filter(Filter_Store; "Store No.") { }

            dataitem(Source_TransSalesEntry; "LSC Trans. Sales Entry")
            {
                DataItemLink = "Transaction No." = Source_TransactionHeader."Transaction No.", "Store No." = Source_TransactionHeader."Store No.", "POS Terminal No." = Source_TransactionHeader."POS Terminal No.";
                SqlJoinType = InnerJoin;

                column(Net_Amount; "Net Amount")
                {
                    Method = Sum;
                }
                column(Count)
                {
                    Method = Count;
                }

                dataitem(Source_Item; "Item")
                {
                    DataItemLink = "No." = Source_TransSalesEntry."Item No.";
                    SqlJoinType = InnerJoin;
                    filter(Filter_Vendor; "Vendor No.") { }
                    filter(Filter_Gen__Prod__Posting_Group; "Gen. Prod. Posting Group") { }
                    column(Vendor_No_; "Vendor No.") { }

                }
            }
        }
    }
}


