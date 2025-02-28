query 50086 CalcTPRSales
{
    ReadState = ReadUncommitted;
    OrderBy = ascending(locationCode, itemNo);

    elements
    {
        dataitem(valueEntry; "Value Entry")
        {
            filter(ileType; "Item Ledger Entry Type") { }
            filter(filterDate; "Posting Date") { }
            filter(filterLocation; "Location Code") { }
            filter(filterItem; "Item No.") { }
            column(itemNo; "Item No.") { }
            column(locationCode; "Location Code") { }
            column(quantity; "Item Ledger Entry Quantity") { Method = Sum; }
            column(salesAmountActual; "Sales Amount (Actual)") { Method = Sum; }
            column(costAmountActual; "Cost Amount (Actual)") { Method = Sum; }
            column(discountAmount; "Discount Amount") { Method = Sum; }
        }
    }
}