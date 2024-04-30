<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

// Project implemented by the &quot;Recovery, Transformation and Resilience Plan.
// Funded by the European Union - Next GenerationEU&quot;.
//
// Produced by the UNIMOODLE University Group: Universities of
// Valladolid, Complutense de Madrid, UPV/EHU, León, Salamanca,
// Illes Balears, Valencia, Rey Juan Carlos, La Laguna, Zaragoza, Málaga,
// Córdoba, Extremadura, Vigo, Las Palmas de Gran Canaria y Burgos.
/**
 * 
 * @package gradeexport_groupfilter_txt
 * @copyright 2023 Proyecto UNIMOODLE {@link https://unimoodle.github.io}
 * @author UNIMOODLE Group (Coordinator) <direccion.area.estrategia.digital@uva.es>
 * @author Joan Carbassa (IThinkUPC) <joan.carbassa@ithinkupc.com>
 * @author Yerai Rodríguez (IThinkUPC) <yerai.rodriguez@ithinkupc.com>
 * @author Marc Geremias (IThinkUPC) <marc.geremias@ithinkupc.com>
 * @author Miguel Gutiérrez (UPCnet) <miguel.gutierrez.jariod@upcnet.es>
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace gradeexport_groupfilter_txt;

/**
 * Class grade_export_form_test
 *
 * This class represents a unit test case for the grade_export_form class
 * in the gradeexport_groupfilter_txt plugin.
 *
 * @coversDefaultClass \gradeexport_groupfilter_txt\grade_export_form
 * @group gradeexport_groupfilter_txt
 */
class  grade_export_form_test extends \advanced_testcase {

    /**
     * Test form_constructor.
     *
     * @covers \gradeexport_groupfilter_txt\grade_export_form::definition
     */
    public function test_form_constructor() {
        $this->resetAfterTest(true);
        $formoptions = [
            'includeseparator' => true,
            'publishing' => true,
            'simpleui' => true,
            'multipledisplaytypes' => true,
        ];
        $mform = new \gradeexport_groupfilter_txt\grade_export_form(null, $formoptions);
        $this->assertNotEmpty($mform, 'userfields created in the form');
    }
}
