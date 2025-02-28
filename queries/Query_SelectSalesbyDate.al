query 50085 "SelectSalesbyDate"
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
            column(TH_Date; "Date")
            {

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

                column(TSE_Item_No; "Item No.")
                {

                }
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

