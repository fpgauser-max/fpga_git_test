`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/27 21:06:37
// Design Name: 
// Module Name: data_write_read
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_write_read(
      clk,
      reset,
      init_calib_complete,
      ddr4_app_en,
      ddr4_app_cmd,
      ddr4_app_addr,
      ddr4_app_wdf_end,
      ddr4_app_wdf_wren,
      ddr4_app_wdf_rdy,
      ddr4_app_rdy,
      ddr4_app_wdf_data,
      ddr4_app_wdf_mask,
      ddr4_app_rd_data,
      ddr4_app_rd_data_end,
      ddr4_app_rd_data_valid
    );
      input                                           clk;
      input                                           reset;
      input                                           init_calib_complete;
      
      output  reg                                        ddr4_app_en;
      output  reg    [2:0]                               ddr4_app_cmd;
      output  reg    [27:0]                              ddr4_app_addr;
      output  reg                                        ddr4_app_wdf_end;
      output  reg                                        ddr4_app_wdf_wren;
      input                                           ddr4_app_wdf_rdy;
      input                                           ddr4_app_rdy;
      output      [511:0]                             ddr4_app_wdf_data;
      output      [63:0]                              ddr4_app_wdf_mask;
      input       [511:0]                             ddr4_app_rd_data;
      input                                           ddr4_app_rd_data_end;
      input                                           ddr4_app_rd_data_valid;
      
    reg     [5:0]      state_ns;
    reg     [5:0]      state_cs;
    
    reg                 ddr4_ready;
    reg                 wr_start;
    reg                 rx_data_end;
    reg                 rd_ddr_end;
    reg                 ddr_rd_start;
    reg                 process_end;
    
    localparam          IDLE        =   6'h1,
//                        WR_WAIT     =   6'd2,
                        WR_DDR      =   6'h2,
                        WAIT        =   6'h4,
                        RD_DDR      =   6'h5,
                        PROC_END    =   6'h6;
                        
   always @(posedge clk or posedge reset)
      if(reset)
         state_cs <= IDLE;
      else 
         state_cs <= state_ns;    
                            
   always @(*)
      if(reset)
            state_ns <= IDLE;
      else begin
            case(state_cs)
                  IDLE:begin
                        if(ddr4_ready)
                              state_ns = WR_DDR;
                        else 
                              state_ns = IDLE;
                       end
                 WR_DDR:begin
                        if(rx_data_end)  
                              state_ns = WAIT;
                        else 
                              state_ns = WR_DDR;
                       end  
                WAIT:begin
                        if(ddr_rd_start)
                              state_ns = RD_DDR;
                        else 
                              state_ns = WAIT;
                     end
                RD_DDR:begin
                        if(rd_ddr_end)
                           state_ns =  PROC_END;
                         else 
                           state_ns = RD_DDR;
                       end
               PROC_END:begin
                        if(process_end)
                           state_ns =  IDLE;
                        else 
                           state_ns =  PROC_END;
                       end
              default:state_ns = IDLE;
              endcase
      end

always @(posedge clk or posedge reset) begin
      if(reset)
         ddr4_ready <= 0;
      else if(init_calib_complete &  ddr4_app_wdf_rdy & ddr4_app_rdy)
         ddr4_ready <= 1;
      else 
         ddr4_ready <= 0;
end
//Ö¸Áî¿ØÖµ
always @(posedge clk or posedge reset) begin
      if(reset) begin
          ddr4_app_en <= 1'b0;
          ddr4_app_cmd <= 3'd0;
      end
      else if(state_cs == WR_DDR) begin
            if(ddr4_app_rdy) begin
                  ddr4_app_en <= 1'b1;
                  ddr4_app_cmd <= 3'b000;
            end
            else begin
                  ddr4_app_en <= 1'b0;
                  ddr4_app_cmd <= 3'b000;
            end
     end
      else if(state_cs == RD_DDR) begin
            if(ddr4_app_rdy) begin
                  ddr4_app_en <= 1'b1;
                  ddr4_app_cmd <= 3'b001;
            end
            else begin
                  ddr4_app_en <= 1'b0;
                  ddr4_app_cmd <= 3'b000;
            end
     end
     else begin
             ddr4_app_en <= 1'b0;
             ddr4_app_cmd <= 3'b000;
     end
end
              
             
      
      
      
endmodule
