# Elevator-Control

This project emulates a real-world elevator setup with a system featuring two lifts capable of serving 10 floors, responding to commands from elevator panels and buttons located each floor.

Project Description:
This project aims to replicate a functional elevator system, comprising two elevators where one acts as a backup in case the primary elevator fails, efficiently serving a 10-floor structure. The system responds to inputs from both in-elevator panels and floor-based buttons. A central control unit (CCU) is in place to determine the destination floors based on floor requests and internal elevator requests, giving priority to the closest and internal calls. Additionally, an elevator control unit (ECU) displays the current floor and status of the elevator, such as whether it is idle, ascending, descending, or in door operation modes. The system is integrated with a PS2 keyboard for input, hex display for floor indication, and VGA for visual representation of the elevator's status.

Initial Project Outline:
The initial idea was to create a realistic two-lift elevator system capable of serving ten floors, with operational panels and buttons on each floor.

Original cost Allocation:
Eric: datapath 0.5/2, PS2 Keyboard&mouse 1
David: datapath 0.5/2, ECU FSM 0.25, switches and key 0.25, LED 0.125, VGA 0.125, handle clock crossing

Final cost Allocation:
Eric: CCU, PS2 Keyboard (with reference from online demo), Keyboard FSM
David: CCU, ECU FSM, switch and keys, HEX, VGA, memory block

Challenges and Future Improvements:

- The secondary elevator was not functional in the initial version.
- Future improvements include making the second elevator operational for enhanced efficiency and incorporating LED and audio alerts for door operations.
