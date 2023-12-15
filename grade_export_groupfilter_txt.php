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
 * Display information about all the gradeexport_groupfilter_txt modules in the requested course. *
 * @package groupfilter_txt
 * @copyright 2023 Proyecto UNIMOODLE
 * @author UNIMOODLE Group (Coordinator) &lt;direccion.area.estrategia.digital@uva.es&gt;
 * @author Joan Carbassa (IThinkUPC) &lt;joan.carbassa@ithinkupc.com&gt;
 * @author Miguel Gutiérrez (UPCnet) &lt;miguel.gutierrez.jariod@upcnet.es&gt;
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

require_once($CFG->dirroot.'/grade/export/lib.php');
require_once($CFG->libdir . '/csvlib.class.php');

class grade_export_groupfilter_txt extends grade_export {

    public $plugin = 'groupfilter_txt';

    public $separator; // Default separator.

    private $formdata;

    /**
     * Constructor should set up all the private variables ready to be pulled
     * @param object $course
     * @param int $groupid id of selected group, 0 means all
     * @param stdClass $formdata The validated data from the grade export form.
     */
    public function __construct($course, $groupid, $formdata) {
        parent::__construct($course, $groupid, $formdata);
        $this->separator = $formdata->separator;
        $this->formdata = $formdata;
        // Overrides.
        $this->usercustomfields = true;
    }

    public function get_export_params() {
        $params = parent::get_export_params();
        $params['separator'] = $this->separator;
        return $params;
    }

    /**
     * Init object based using data from form
     * @param object $formdata
     */
    public function process_form($formdata) {
        parent::process_form($formdata);
    }

    public static function export_bulk_export_data($id, $itemids, $exportfeedback, $onlyactive, $displaytype,
                                                   $decimalpoints, $updatedgradesonly = null, $separator = null) {
        $form = parent::export_bulk_export_data($id, $itemids, $exportfeedback, $onlyactive, $displaytype,
            $decimalpoints, $updatedgradesonly = null, $separator = null);
        return $form;
    }

    public function print_grades() {
        global $CFG;
        $exporttracking = $this->track_exports();

        $strgrades = get_string('grades');
        $profilefields = grade_helper::get_user_profile_fields($this->course->id, $this->usercustomfields);
        // Obtain selected fields from user formdata.
        $profilefieldsselected = [];
        foreach ($this->formdata as $key => $data) {
            if (mb_strpos($key, "userfieldsvisbile_") !== false) {
                $value = str_replace("userfieldsvisbile_", "", $key);
                array_push($profilefieldsselected, $value);
            }
        }

        // Edit fields only choosing the selected ones.
        foreach ($profilefields as $key => $fields) {
            if ($profilefieldsselected !== null && !in_array($fields->shortname, $profilefieldsselected)) {
                unset($profilefields[$key]);
            }
        }

        $shortname = format_string($this->course->shortname, true, ['context' => context_course::instance($this->course->id)]);
        $downloadfilename = clean_filename("$shortname $strgrades");
        $csvexport = new csv_export_writer($this->separator);
        $csvexport->set_filename($downloadfilename);

        // Print names of all the fields.
        $exporttitle = [];

        // Added column Groups.
        $exporttitle[] .= get_string('group', 'gradeexport_groupfilter_txt');

        foreach ($profilefields as $field) {
            $exporttitle[] = $field->fullname;
        }
        if (!$this->onlyactive) {
            $exporttitle[] = get_string("suspended");
        }

        // Add grades and feedback columns.
        foreach ($this->columns as $gradeitem) {
            foreach ($this->displaytype as $gradedisplayname => $gradedisplayconst) {
                $exporttitle[] = $this->format_column_name($gradeitem, false, $gradedisplayname);
            }
            if ($this->export_feedback) {
                $exporttitle[] = $this->format_column_name($gradeitem, true);
            }
        }
        // Last downloaded column header.
        $exporttitle[] = get_string('timeexported', 'gradeexport_groupfilter_txt');
        $csvexport->add_data($exporttitle);

        // Print all the lines of data.
        $geub = new grade_export_update_buffer();

        // Obtain list of the groups.
        $groups = groups_get_all_groups($this->course->id);
        $this->course->groupmode = VISIBLEGROUPS;
        // Obtain the groupid selected on visible groups filter.
        $groupid = groups_get_course_group($this->course, true);
        // Set all participants by default in case of not having groups.
        if (!$groupid) {
            $groupid = 0;
        }

        if (!empty($groups)) {
            // All participants format.
            if ($groupid == 0) {
                foreach ($groups as $usergroup) {
                    $gui = new graded_users_iterator($this->course, $this->columns, $usergroup->id);
                    $gui->require_active_enrolment($this->onlyactive);
                    $gui->allow_user_custom_fields($this->usercustomfields);
                    $gui->init();
                    while ($userdata = $gui->next_user()) {
                        $exportdata = [];
                        $user = $userdata->user;
                        if (groups_is_member($usergroup->id, $user->id)) {
                            $exportdata[] = $usergroup->name;
                            foreach ($profilefields as $field) {
                                $fieldvalue = grade_helper::get_user_field_value($user, $field);
                                $exportdata[] = $fieldvalue;
                            }
                            if (!$this->onlyactive) {
                                $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                                $exportdata[] = $issuspended;
                            }
                            foreach ($userdata->grades as $itemid => $grade) {
                                if ($exporttracking) {
                                    $status = $geub->track($grade);
                                }

                                foreach ($this->displaytype as $gradedisplayconst) {
                                    $exportdata[] = $this->format_grade($grade, $gradedisplayconst);
                                }

                                if ($this->export_feedback) {
                                    $exportdata[] = $this->format_feedback($userdata->feedbacks[$itemid], $grade);
                                }
                            }
                            // Time exported.
                            $exportdata[] = time();
                            $csvexport->add_data($exportdata);
                        }
                    }
                }
                // Obtain users that has group (not considering all participants).
                $arraygroupsid = [];
                foreach ($groups as $group) {
                    $arraygroupsid[] += $group->id;
                }
                $usersingroup = groups_get_groups_members($arraygroupsid);

                $gui = new graded_users_iterator($this->course, $this->columns, $this->groupid);
                $gui->require_active_enrolment($this->onlyactive);
                $gui->allow_user_custom_fields($this->usercustomfields);
                $gui->init();

                while ($userdata = $gui->next_user()) {
                    $exportdata = [];
                    $user = $userdata->user;

                    // Check user is from the group.
                    $exists = false;
                    foreach ($usersingroup as $usergroup) {
                        if ($usergroup->id == $user->id) {
                            $exists = true;
                        }
                    }

                    if (!$exists) {
                        $exportdata[] = "";
                        foreach ($profilefields as $field) {
                            $fieldvalue = grade_helper::get_user_field_value($user, $field);
                            $exportdata[] = $fieldvalue;
                        }
                        if (!$this->onlyactive) {
                            $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                            $exportdata[] = $issuspended;
                        }
                        foreach ($userdata->grades as $itemid => $grade) {
                            if ($exporttracking) {
                                $status = $geub->track($grade);
                            }

                            foreach ($this->displaytype as $gradedisplayconst) {
                                $exportdata[] = $this->format_grade($grade, $gradedisplayconst);
                            }

                            if ($this->export_feedback) {
                                $exportdata[] = $this->format_feedback($userdata->feedbacks[$itemid], $grade);
                            }
                        }
                        // Time exported.
                        $exportdata[] = time();
                        $csvexport->add_data($exportdata);
                    }
                }
            } else { // Group format.
                $gui = new graded_users_iterator($this->course, $this->columns, $this->groupid);
                $gui->require_active_enrolment($this->onlyactive);
                $gui->allow_user_custom_fields($this->usercustomfields);
                $gui->init();
                while ($userdata = $gui->next_user()) {
                    $exportdata = [];
                    $user = $userdata->user;
                    if (groups_is_member($groupid, $user->id)) {
                        $exportdata[] = groups_get_group_name($groupid);
                        foreach ($profilefields as $field) {
                            $fieldvalue = grade_helper::get_user_field_value($user, $field);
                            $exportdata[] = $fieldvalue;
                        }
                        if (!$this->onlyactive) {
                            $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                            $exportdata[] = $issuspended;
                        }
                        foreach ($userdata->grades as $itemid => $grade) {
                            if ($exporttracking) {
                                $status = $geub->track($grade);
                            }

                            foreach ($this->displaytype as $gradedisplayconst) {
                                $exportdata[] = $this->format_grade($grade, $gradedisplayconst);
                            }

                            if ($this->export_feedback) {
                                $exportdata[] = $this->format_feedback($userdata->feedbacks[$itemid], $grade);
                            }
                        }
                        // Time exported.
                        $exportdata[] = time();
                        $csvexport->add_data($exportdata);
                    }
                }
            }
        } else { // No group case.
            $gui = new graded_users_iterator($this->course, $this->columns, $this->groupid);
            $gui->require_active_enrolment($this->onlyactive);
            $gui->allow_user_custom_fields($this->usercustomfields);
            $gui->init();
            while ($userdata = $gui->next_user()) {
                $exportdata = [];
                $user = $userdata->user;
                $exportdata[] = "";
                foreach ($profilefields as $field) {
                    $fieldvalue = grade_helper::get_user_field_value($user, $field);
                    $exportdata[] = $fieldvalue;
                }
                if (!$this->onlyactive) {
                    $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                    $exportdata[] = $issuspended;
                }
                foreach ($userdata->grades as $itemid => $grade) {
                    if ($exporttracking) {
                        $status = $geub->track($grade);
                    }

                    foreach ($this->displaytype as $gradedisplayconst) {
                        $exportdata[] = $this->format_grade($grade, $gradedisplayconst);
                    }

                    if ($this->export_feedback) {
                        $exportdata[] = $this->format_feedback($userdata->feedbacks[$itemid], $grade);
                    }
                }
                // Time exported.
                $exportdata[] = time();
                $csvexport->add_data($exportdata);

            }
        }
        $gui->close();
        $geub->close();
        $csvexport->download_file();
        exit;
    }
}


