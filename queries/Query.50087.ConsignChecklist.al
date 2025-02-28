query 50087 GetConsignSales
{
    ReadState = ReadUncommitted;
    OrderBy = ascending(storeNo, itemNo);
    QueryCategory = 'TPF';

    elements
    {
        dataitem(dailyConsignSalesDet; "Daily Consign. Sales Details")
        {
            filter(filterDate; Date) { }
            filter(filterLocation; "Store No.") { }
            filter(filterItem; "Item No.") { }
            //  column(Date; Date) { }
            column(itemNo; "Item No.") { }
            column(storeNo; "Store No.") { }
            column(profitExclTax; "Consignment Amount") { Method = Sum; }
            column(totalInclTax; "Total Incl Tax") { Method = Sum; }
            column(totalExclTax; "Total Excl Tax") { Method = Sum; }
            column(discountAmount; "Discount Amount") { Method = Sum; }

        }
    }
}