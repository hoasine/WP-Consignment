query 50080 "SelectConsignPostedSales"
{
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(Source_TransactionHeader; "LSC Transaction Header")
        {
            DataItemTableFilter = "Entry Status" = filter('' | Voided);

            filter(Filter_Date; "Date") { }
            filter(Filter_Store; "Store No.") { }

            dataitem(LSC_Transaction_Status; "LSC Transaction Status")
            {
                DataItemLink = "Transaction No." = Source_TransactionHeader."Transaction No.", "Store No." = Source_TransactionHeader."Store No.", "POS Terminal No." = Source_TransactionHeader."POS Terminal No.";
                SqlJoinType = InnerJoin;

                column(Status; Status) { }

                dataitem(Source_TransSalesEntry; "LSC Trans. Sales Entry")
                {
                    DataItemLink = "Transaction No." = LSC_Transaction_Status."Transaction No.", "Store No." = LSC_Transaction_Status."Store No.", "POS Terminal No." = LSC_Transaction_Status."POS Terminal No.";
                    SqlJoinType = InnerJoin;

                    column(TSE_Sum_Excl_Tax; "Net Amount")
                    {
                        Method = Sum;
                    }
                    column(TSE_Sum_Tax; "VAT Amount")
                    {
                        Method = Sum;
                    }
                    column(TSE_Sum_Qty; "Quantity")
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
                        filter(Filter_Vendor; "Vendor No.")
                        {

                        }

                        filter(Filter_Gen__Prod__Posting_Group; "Gen. Prod. Posting Group")
                        {

                        }

                        column(Vendor_No_; "Vendor No.")
                        {

                        }

                        column(Gen__Prod__Posting_Group; "Gen. Prod. Posting Group")
                        {

                        }


                    }
                }
            }
        }
    }
}

