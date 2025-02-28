query 50084 "SelectDistinctSalesCount"
{
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(Source_TransactionHeader; "LSC Transaction Header")
        {
            DataItemTableFilter = "Entry Status" = filter('' | Voided);

            filter(Filter_Date; "Date")
            {

            }

            filter(Filter_Store; "Store No.")
            {

            }
            column(Receipt_No_; "Receipt No.")
            {

            }

            column(Date; Date)
            {

            }

            column(Count)
            {
                Method = Count;
            }
            dataitem(Source_TransSalesEntry; "LSC Trans. Sales Entry")
            {
                DataItemLink = "Transaction No." = Source_TransactionHeader."Transaction No.", "Store No." = Source_TransactionHeader."Store No.", "POS Terminal No." = Source_TransactionHeader."POS Terminal No.";
                SqlJoinType = InnerJoin;
                filter(Filter_Division; "Division Code")
                {

                }
                filter(Filter_ItemCategory; "Item Category Code")
                {

                }
                filter(Filter_ProductGroup; "Retail Product Code")
                {

                }

                filter(Filter_Item; "Item No.")
                {

                }

                dataitem(Source_Item; "Item")
                {
                    DataItemLink = "No." = Source_TransSalesEntry."Item No.";
                    SqlJoinType = InnerJoin;
                    filter(Filter_Vendor; "Vendor No.")
                    {

                    }
                }
            }
        }
    }
}

