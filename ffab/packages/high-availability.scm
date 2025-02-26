;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2022 Sharlatan Hellseher <sharlatanus@gmail.com>
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (ffab packages high-availability)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages hardware)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages valgrind)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module ((guix licenses)
                #:prefix license:))

;; 20220925T203920+0100
(define-public kronosnet
  (package
    (name "kronosnet")
    (version "1.24")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/kronosnet/kronosnet")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1b8rz7f2h3scrq0xcqz58ckzsvv08g31j5jgy2v4i6w87r9c75lw"))))
    (build-system gnu-build-system)
    (arguments
     ;; TODO: (Sharlatan-20220925T203354+0100): Multiple tests failed. Tests
     ;; require very complex environment and for some of them root privileges to
     ;; set network configuration. It has it's own CI based on Jenkis
     ;; https://ci.kronosnet.org/.
     (list #:tests? #f
           #:phases #~(modify-phases %standard-phases
                        (add-before 'bootstrap 'fix-version-gen
                          (lambda _
                            (call-with-output-file ".tarball-version"
                              (lambda (port)
                                (display #$version port))))))))
    (native-inputs (list autoconf
                         automake
                         doxygen
                         libtool
                         net-tools
                         pkg-config
                         ;; libgcc_s.so.1 must be installed for pthread_cancel to work
                         `(,gcc "lib")))
    (inputs (list lksctp-tools
                  libnl
                  libqb
                  libxml2
                  lz4
                  lzo
                  nss
                  nspr
                  openssl
                  xz
                  zlib
                  `(,zstd "lib")))
    (home-page "https://kronosnet.org/")
    (synopsis "Network abstraction layer designed for High Availability")
    (description
     "Kronosnet, often referred to as @code{knet}, is a network
 abstraction layer designed for High Availability use cases, where redundancy,
 security, fault tolerance and fast fail-over are the core requirements of
 your application.

 Kronosnet is the new underlying network protocol for Linux HA components
 (Corosync), that features ability to use multiple links between nodes,
 active/active and active/passive link failover policies, automatic link
 recovery, FIPS compliant encryption (nss and/or openssl), automatic PMTUd and
 in general better performances compared to the old network protocol.")
    (license (list license:gpl2+ license:lgpl2.1+))))

;; 20220925T203925+0100
(define-public corosync
  (package
    (name "corosync")
    (version "3.1.6")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/corosync/corosync")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "03g3qnm5acmk7jry6kspvkssbiv8k39749bic2f0cj3ckkwy2li4"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases #~(modify-phases %standard-phases
                        (add-before 'bootstrap 'fix-version-gen
                          (lambda _
                            (call-with-output-file ".tarball-version"
                              (lambda (port)
                                (display #$version port))))))))
    (native-inputs (list autoconf automake libtool pkg-config))
    (inputs (list kronosnet libqb))
    (home-page "https://corosync.github.io/corosync/")
    (synopsis
     "Group communication system for implementing High Availability in applications")
    (description
     "The Corosync Cluster Engine is a Group Communication System with additional
features for implementing high availability within applications. The project
provides four C Application Programming Interface features:

@itemize

@item A closed process group communication model with extended virtual synchrony
guarantees for creating replicated state machines.

@item A simple availability manager that restarts the application process when
it has failed.

@item A configuration and statistics in-memory database that provide the ability
to set, retrieve, and receive change notifications of information.

@item A quorum system that notifies applications when quorum is achieved or
lost.

@end itemize")
    (license (list license:bsd-0 license:gpl3))))

;; 20220925T203913+0100
(define-public pacemaker
  (package
    (name "pacemaker")
    (version "2.1.4")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ClusterLabs/pacemaker")
                    (commit (string-append "Pacemaker-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "04gfd7i3w0zbzv7vi7728lgbyjq7cbqpr7jsp501piwg3z5j4mvb"))))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags #~(list "--with-corosync"
                                     (string-append "--with-initdir="
                                                    #$output "/etc/init.d")
                                     (string-append "--with-ocfdir="
                                                    #$output "/lib"))))
    (native-inputs (list autoconf
                         automake
                         cmocka
                         gettext-minimal
                         libtool
                         pkg-config
                         rsync
                         util-linux
                         valgrind))
    (inputs (list dbus
                  corosync
                  glib
                  gnutls
                  libqb
                  libxml2
                  libxslt
                  python
                  `(,util-linux "lib")))
    (home-page "https://www.clusterlabs.org/pacemaker/")
    (synopsis "Scalable High-Availability cluster resource manager")
    (description
     "Pacemaker is a high-availability cluster resource manager.

It achieves maximum availability for your cluster services (a.k.a. resources) by
detecting and recovering from node- and resource-level failures by making use of
the messaging and membership capabilities provided by Corosync.

It can do this for clusters of practically any size and comes with a powerful
dependency model that allows the administrator to accurately express the
relationships (both ordering and location) between the cluster resources.

Virtually anything that can be scripted can be managed as part of a Pacemaker cluster.")
    (license (list license:cc-by4.0 license:gpl2+ license:lgpl2.1+))))
