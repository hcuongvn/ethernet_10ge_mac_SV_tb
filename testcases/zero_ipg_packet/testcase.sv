//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : zero_ipg_packet/testcase.sv                         //
//  Author    : G. Andres Mancera                                   //
//  License   : GNU Lesser General Public License                   //
//  Course    : Advanced Verification with SystemVerilog OOP        //
//              Testbench - UCSC Silicon Valley Extension           //
//                                                                  //
//////////////////////////////////////////////////////////////////////

`include "../../testbench/packet.sv"
`include "../../testbench/driver.sv"
`include "../../testbench/monitor.sv"
`include "../../testbench/coverage.sv"
`include "../../testbench/scoreboard.sv"
`include "../../testbench/env.sv"

program testcase (  interface tcif_driver,
                    interface tcif_monitor  );

  class zero_ipg_packet extends packet;
    constraint C_ipg
    {
      ipg   == 0;
    }
  endclass : zero_ipg_packet

  env               env0;
  int unsigned      num_packets;
  zero_ipg_packet   testcase_packet;

  initial begin
    env0            = new(tcif_driver, tcif_monitor);
    testcase_packet = new();

    // Connect packet handle from driver to testcase_packet
    env0.drv.xge_mac_pkt = testcase_packet;
    num_packets = $urandom_range(40,60);
    tcif_driver.init_tb_signals();
    tcif_driver.make_loopback_connection();
    tcif_driver.wait_ns(2000);
    env0.run(num_packets);
    tcif_driver.wait_ns(100000);
    $finish;
  end

  final begin
    int unsigned    num_pkts;
    int unsigned    num_errors;
    num_pkts    =   packet::get_pktid();
    num_errors  =   env0.scbd.num_of_mismatches;
    $display("\nTESTCASE: ----------------- End Of Simulation -----------------");
    $display("TESTCASE: Number of packets sent       :  %0d", num_pkts);
    $display("TESTCASE: Number of mismatched packets :  %0d", num_errors);
    if ( num_errors==0 )
      $display("TESTCASE: ---------------------- PASSED -----------------------\n");
    else
      $display("TESTCASE: ---------------------- FAILED -----------------------\n");
  end

endprogram
