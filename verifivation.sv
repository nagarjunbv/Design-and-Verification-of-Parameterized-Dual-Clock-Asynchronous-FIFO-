module fifo_assertions #(
    parameter PTR_WIDTH = 5
)(
    input logic                 wr_clk,
    input logic                 rd_clk,
    input logic                 wr_rst,
    input logic                 rd_rst,

    input logic                 wr_en,
    input logic                 rd_en,

    input logic                 full,
    input logic                 empty,

    input logic [PTR_WIDTH-1:0] wr_ptr_bin,
    input logic [PTR_WIDTH-1:0] rd_ptr_bin,

    input logic [PTR_WIDTH-1:0] wr_ptr_gray,
    input logic [PTR_WIDTH-1:0] rd_ptr_gray,

    input logic [PTR_WIDTH-1:0] rd_ptr_gray_sync1,
    input logic [PTR_WIDTH-1:0] rd_ptr_gray_sync2,

    input logic [PTR_WIDTH-1:0] wr_ptr_gray_sync1,
    input logic [PTR_WIDTH-1:0] wr_ptr_gray_sync2
);


////////////////////////////////////////////////////////////
// 1. Do not advance write pointer when FIFO is full
////////////////////////////////////////////////////////////

property p_no_write_when_full;
    @(posedge wr_clk)
    disable iff (wr_rst)

    (wr_en && full)
    |=> $stable(wr_ptr_bin);
endproperty

assert property (p_no_write_when_full);


////////////////////////////////////////////////////////////
// 2. Do not advance read pointer when FIFO is empty
////////////////////////////////////////////////////////////

property p_no_read_when_empty;
    @(posedge rd_clk)
    disable iff (rd_rst)

    (rd_en && empty)
    |=> $stable(rd_ptr_bin);
endproperty

assert property (p_no_read_when_empty);


////////////////////////////////////////////////////////////
// 3. Write pointer increments after valid write
////////////////////////////////////////////////////////////

property p_write_pointer_increment;
    @(posedge wr_clk)
    disable iff (wr_rst)

    (wr_en && !full)
    |=> wr_ptr_bin == $past(wr_ptr_bin) + 1'b1;
endproperty

assert property (p_write_pointer_increment);


////////////////////////////////////////////////////////////
// 4. Read pointer increments after valid read
////////////////////////////////////////////////////////////

property p_read_pointer_increment;
    @(posedge rd_clk)
    disable iff (rd_rst)

    (rd_en && !empty)
    |=> rd_ptr_bin == $past(rd_ptr_bin) + 1'b1;
endproperty

assert property (p_read_pointer_increment);


////////////////////////////////////////////////////////////
// 5. Write pointer must remain stable without valid write
////////////////////////////////////////////////////////////

property p_write_pointer_stable;
    @(posedge wr_clk)
    disable iff (wr_rst)

    !(wr_en && !full)
    |=> $stable(wr_ptr_bin);
endproperty

assert property (p_write_pointer_stable);


////////////////////////////////////////////////////////////
// 6. Read pointer must remain stable without valid read
////////////////////////////////////////////////////////////

property p_read_pointer_stable;
    @(posedge rd_clk)
    disable iff (rd_rst)

    !(rd_en && !empty)
    |=> $stable(rd_ptr_bin);
endproperty

assert property (p_read_pointer_stable);


////////////////////////////////////////////////////////////
// 7. Binary-to-Gray conversion - Write pointer
////////////////////////////////////////////////////////////

property p_write_gray_conversion;
    @(posedge wr_clk)
    disable iff (wr_rst)

    wr_ptr_gray == (wr_ptr_bin ^ (wr_ptr_bin >> 1));
endproperty

assert property (p_write_gray_conversion);


////////////////////////////////////////////////////////////
// 8. Binary-to-Gray conversion - Read pointer
////////////////////////////////////////////////////////////

property p_read_gray_conversion;
    @(posedge rd_clk)
    disable iff (rd_rst)

    rd_ptr_gray == (rd_ptr_bin ^ (rd_ptr_bin >> 1));
endproperty

assert property (p_read_gray_conversion);


////////////////////////////////////////////////////////////
// 9. Write Gray pointer changes only one bit
////////////////////////////////////////////////////////////

property p_write_gray_one_bit_change;
    @(posedge wr_clk)
    disable iff (wr_rst)

    (wr_en && !full)
    |=> $onehot(wr_ptr_gray ^ $past(wr_ptr_gray));
endproperty

assert property (p_write_gray_one_bit_change);


////////////////////////////////////////////////////////////
// 10. Read Gray pointer changes only one bit
////////////////////////////////////////////////////////////

property p_read_gray_one_bit_change;
    @(posedge rd_clk)
    disable iff (rd_rst)

    (rd_en && !empty)
    |=> $onehot(rd_ptr_gray ^ $past(rd_ptr_gray));
endproperty

assert property (p_read_gray_one_bit_change);


////////////////////////////////////////////////////////////
// 11. Write pointer 2-FF synchronization into read domain
////////////////////////////////////////////////////////////

property p_wr_sync_second_stage;
    @(posedge rd_clk)
    disable iff (rd_rst)

    wr_ptr_gray_sync2 == $past(wr_ptr_gray_sync1);
endproperty

assert property (p_wr_sync_second_stage);


////////////////////////////////////////////////////////////
// 12. Read pointer 2-FF synchronization into write domain
////////////////////////////////////////////////////////////

property p_rd_sync_second_stage;
    @(posedge wr_clk)
    disable iff (wr_rst)

    rd_ptr_gray_sync2 == $past(rd_ptr_gray_sync1);
endproperty

assert property (p_rd_sync_second_stage);


////////////////////////////////////////////////////////////
// COVER PROPERTIES
////////////////////////////////////////////////////////////

// FIFO experiences a successful write
cover property (
    @(posedge wr_clk)
    disable iff (wr_rst)
    wr_en && !full
);


// FIFO reaches full
cover property (
    @(posedge wr_clk)
    disable iff (wr_rst)
    full
);


// FIFO experiences successful read
cover property (
    @(posedge rd_clk)
    disable iff (rd_rst)
    rd_en && !empty
);


// FIFO reaches empty
cover property (
    @(posedge rd_clk)
    disable iff (rd_rst)
    empty
);


endmodule
